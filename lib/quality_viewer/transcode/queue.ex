defmodule QualityViewer.Transcode.Queue do
  use GenServer
  alias QualityViewer.Transcode.Worker
  require Logger

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def enqueue(path, quality, id) do
    GenServer.cast(__MODULE__, {:enqueue, path, quality, id})
  end

  @default_pool_size 1

  defp pool_size() do
    Application.get_env(:quality_viewer, :transcode_pool_size, @default_pool_size)
  end

  @impl true
  def init(_opts) do
    size = pool_size()
    monitors = %{}

    workers =
      for _ <- 1..size do
        {:ok, pid} = Worker.start_link(self())
        ref = Process.monitor(pid)
        Map.put(monitors, pid, ref)
        pid
      end

    {:ok,
     %{
       available_workers: workers,
       busy_workers: %{},
       queue: [],
       monitors: monitors
     }}
  end

  @impl true
  def handle_cast({:enqueue, path, quality, id}, state) do
    Logger.log(:info, "[QUEUE] Enqueueing #{id} with quality #{inspect(quality)}")

    case state.available_workers do
      [worker | rest] ->
        Logger.log(:info, "[QUEUE] Worker #{inspect(worker)} available, scheduling task (#{id})")
        GenServer.cast(worker, {:run, {path, quality, id}})
        new_busy = Map.put(state.busy_workers, worker, {path, quality, id})
        {:noreply, %{state | busy_workers: new_busy, available_workers: rest}}

      [] ->
        {:noreply, %{state | queue: [{path, quality, id} | state.queue]}}
    end
  end

  @impl true
  def handle_info({:worker_done, worker_pid}, state) do
    Logger.log(:info, "[QUEUE] received worker_done from #{inspect(worker_pid)}")
    new_busy = Map.delete(state.busy_workers, worker_pid)
    new_state = %{state | busy_workers: new_busy}

    case new_state.queue do
      [next_job | rest] ->
        Logger.log(:info, "[QUEUE] next_job available, scheduling it for #{inspect(worker_pid)}")
        GenServer.cast(worker_pid, {:run, next_job})
        final_busy = Map.put(new_state.busy_workers, worker_pid, next_job)
        {:noreply, %{new_state | busy_workers: final_busy, queue: rest}}

      [] ->
        Logger.log(:info, "[QUEUE] no next job available, resting the worker")
        {:noreply, %{new_state | available_workers: [worker_pid | new_state.available_workers]}}
    end
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    was_busy = Map.get(state.busy_workers, pid)

    state
    |> remove_down_worker(pid)

    {:ok, new_worker} = Worker.start_link(self())
    new_ref = Process.monitor(new_worker)

    %{
      state
      | available_workers: [new_worker | state.available_workers],
        monitors: Map.put(state.monitors, new_worker, new_ref)
    }

    state =
      case was_busy do
        nil -> state
        job -> %{state | queue: state.queue ++ [job]}
      end

    re_dispatch_jobs(state)
  end

  defp remove_down_worker(state, pid) do
    %{
      state
      | available_workers: Enum.reject(state.available_workers, fn worker -> worker == pid end),
        busy_workers: Map.delete(state.busy_workers, pid),
        monitors: Map.delete(state.monitors, pid)
    }
  end

  defp re_dispatch_jobs(state) do
    case {state.available_workers, state.queue} do
      {[worker | rest_workers], [job | rest_jobs]} ->
        GenServer.cast(worker, {:run, job})
        busy = Map.put(state.busy_workers, worker, job)

        re_dispatch_jobs(%{
          state
          | available_workers: rest_workers,
            queue: rest_jobs,
            busy_workers: busy
        })

      _ ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_call(:reset, _from, _state) do
    size = pool_size()
    monitors = %{}

    workers =
      for _ <- 1..size do
        {:ok, pid} = Worker.start_link(self())
        ref = Process.monitor(pid)
        Map.put(monitors, pid, ref)
        pid
      end

    new_state = %{
      available_workers: workers,
      busy_workers: %{},
      queue: [],
      monitors: monitors
    }

    {:reply, :ok, new_state}
  end
end
