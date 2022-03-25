defmodule PictureThis.GameServer do
  alias PictureThis.GameSupervisor
  use GenServer
  require Logger

  defstruct [
    :topic,
    :id,
    :score_board,
    :total_rounds,
    :current_round,
    :current_prompt,
    players: %{},
    status: :pending
  ]

  @impl true
  def init(args) do
    Logger.debug("init")
    {:ok, args}
  end

  def start_link([game_id]) do
    state = %__MODULE__{topic: topic(game_id), id: game_id}
    name = {:via, Registry, {GameRegistry, game_id, []}}
    GenServer.start_link(__MODULE__, state, name: name)
  end

  def create_game() do
    id = generate_id()

    with {:ok, _} <-
           DynamicSupervisor.start_child(
             GameSupervisor,
             {__MODULE__, [id]}
           ) do
      {:ok, id}
    end
  end

  def via_tuple(game_id) do
    {:via, Registry, {GameRegistry, game_id}}
  end

  def topic(id) do
    "game:#{id}"
  end

  def generate_id() do
    :crypto.strong_rand_bytes(16)
    |> Base.encode64(padding: false)
  end

  def join(game_id, player_id, player_name) do
    game_id
    |> via_tuple()
    |> GenServer.call({:join, {player_id, player_name}})
  end

  def start_game(game_id) do
    game_id
    |> via_tuple()
    |> GenServer.call(:start)
  end

  def guess(game_id, guess, player_id) do
    game_id
    |> via_tuple()
    |> GenServer.call({:guess, guess, player_id})
  end

  @impl true
  def handle_call({:join, {player_id, player_name}}, _from, state) do
    {:reply, :ok, %{state | players: Map.put(state.players, player_id, player_name)}}
  end

  def handle_call(:start, _from, state) do
    # choose drawer choose prompt
    prompt =
      [
        "Angel",
        "Eyeball",
        "Pizza",
        "Angry",
        "Fireworks",
        "Pumpkin",
        "Baby",
        "Flower",
        "Rainbow",
        "Beard",
        "Flying saucer",
        "Recycle",
        "Bible",
        "Giraffe",
        "Sand castle",
        "Bikini",
        "Glasses",
        "Snowflake",
        "Book",
        "High heels",
        "Stairs",
        "Bucket",
        "Ice cream cone",
        "Starfish",
        "Bumble bee",
        "Igloo",
        "Strawberry",
        "Butterfly",
        "Lady bug",
        "Sun",
        "Camera",
        "Lamp",
        "Tire",
        "Cat",
        "Lion",
        "Toast",
        "Church",
        "Mailbox",
        "Toothbrush",
        "Crayon",
        "Night",
        "Toothpaste",
        "Dolphin",
        "Nose",
        "Truck",
        "Egg",
        "Olympics",
        "Volleyball",
        "Eiffel Tower",
        "Peanut"
      ]
      |> Enum.random()
      |> String.downcase()

    IO.inspect(state.players)
    {drawer, _} = Enum.random(state.players)
    broadcast(state.topic, {:game_started, %{prompt: prompt, drawer: drawer}})
    Process.send_after(self(), :round_over, :timer.seconds(30))
    {:reply, :ok, %{state | status: :active, current_prompt: prompt}}
  end

  def handle_call({:guess, guess, player_id}, _from, state) do
    if guess == state.current_prompt do
      Logger.debug("you win")
      broadcast(state.topic, {:winner, %{player_name: state.players[player_id]}})
      # award points, end round, start round, add new prompt
      {:reply, true, state}
    else
      {:reply, false, state}
    end
  end

  @impl true
  def handle_info(:round_over, state) do
    broadcast(state.topic, "end-round")
    {:noreply, state}
  end

  defp broadcast(topic, payload) do
    Logger.debug("game server broadcasting - #{inspect(topic)} - #{inspect(payload)}")

    Phoenix.PubSub.broadcast(PictureThis.PubSub, topic, payload)
  end
end
