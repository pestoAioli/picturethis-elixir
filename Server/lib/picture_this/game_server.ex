defmodule PictureThis.GameServer do
  use GenServer
  require Logger

  defstruct [
    :topic,
    :id,
    :score_board,
    :current_drawer,
    :total_rounds,
    :current_round,
    :current_prompt,
    players: [],
    status: :pending
  ]

  @impl true
  def init(args) do
    {:ok, args}
  end

  def start_link([game_id, creator_id]) do
    state = %__MODULE__{topic: topic(game_id), players: [creator_id], id: game_id}
    GenServer.start_link(__MODULE__, state)
  end

  def topic(id) do
    "game:#{id}"
  end

  def generate_id() do
    :crypto.strong_rand_bytes(16)
    |> Base.encode64(padding: false)
  end

  def join(pid, player_id) do
    GenServer.call(pid, {:join, player_id})
  end

  def start_game(pid) do
    GenServer.call(pid, :start)
  end

  def guess(pid, guess, player_id) do
    GenServer.call(pid, {:guess, guess, player_id})
  end

  @impl true
  def handle_call({:join, player_id}, _from, state) do
    {:reply, :ok, %{state | players: [player_id | state.players]}}
  end

  def handle_call(:start, _from, state) do
    # choose drawer choose prompt
    prompt = "Michael Scott"
    drawer = Enum.random(state.players)
    broadcast(state.topic, {:game_started, %{prompt: prompt, drawer: drawer}})
    {:reply, :ok, %{state | status: :active}}
  end

  def handle_call({:guess, guess, player_id}, _from, state) do
    if guess == state.current_prompt do
      # award points, end round, start round, add new prompt
      {:reply, true, state}
    else
      {:reply, false, state}
    end
  end

  defp broadcast(topic, payload) do
    Logger.debug("game server broadcasting - #{inspect(topic)} - #{inspect(payload)}")

    Phoenix.PubSub.broadcast(PictureThis.PubSub, topic, payload)
  end
end