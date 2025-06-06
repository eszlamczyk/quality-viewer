defmodule QualityViewer.Transcode.Queue do
  use GenServer
  alias QualityViewer.Transcode.Worker

  def start_link(_opts), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  def enqueue(path, quality, id) do
    GenServer.cast(__MODULE__, {:enqueue, path, quality, id})
  end

  @impl true
  def handle_cast({:enqueue, path, quality, id}, state) do
    Task.start(fn -> Worker.run(path, quality, id) end)
    {:noreply, state}
  end
end
