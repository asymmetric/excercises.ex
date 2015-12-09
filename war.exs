defmodule Dealer do
  @suits 'CH'
  @ranks '23456789'
  @count 12

  def start do
    import Enum

    cards = for suit <- @suits, rank <- @ranks, do: [ suit, rank ]

    cards =
      cards
      |> shuffle
      |> take(@count)
      |> split(div(@count, 2))

    one = spawn(Player, :loop, [ elem(cards, 0) ])
    two = spawn(Player, :loop, [ elem(cards, 1) ])

    loop(%{}, one, two, [], [])
  end

  defp loop(%{}, player_one, player_two, player1_cards, player2_cards) do
    IO.puts "Empty stack, we're in a battle"
    send player_one, { self, :card }
    send player_two, { self, :card }
    cards = receive_cards(player_one, player_two)

    IO.puts "cards #{inspect cards}"

    case compare(cards) do
      { :winner, :one } ->
        IO.puts "#{inspect player_one} won the battle!"
      { :winner, :two } ->
        IO.puts "#{inspect player_two} won the battle!"
      { :war } ->
        IO.puts "We have a war!"
    end
  end

  defp loop(pile, player_one, player_two, player1_cards, player2_cards) do
    IO.puts "The pile is #{Enum.join(pile, ",")}"
    send player_one, { self, :cards }
    send player_two, { self, :cards }
  end

  defp receive_cards(player_one, player_two, play_count \\ 0, pile_one \\ Map.new, pile_two \\ Map.new)

  # second card received
  defp receive_cards(player_one, player_two, 1, pile_one, pile_two) do
    receive do
      { pid, :card, card } ->
        IO.puts "Player #{inspect pid} played #{card}"
        cond do
          pid == player_one -> { card, pile_two }
          pid == player_two -> { pile_one, card }
        end
      { pid, :cards, cards } ->
        IO.puts "Player #{inspect pid} played #{cards}"
    end
  end

  # first card received
  defp receive_cards(player_one, player_two, play_count, pile_one, pile_two) do
    receive do
      { pid, :card, card } ->
        IO.puts "Player #{inspect pid} played #{card}"
        case pid do
          player_one ->
            receive_cards(player_one, player_two, play_count + 1, card, pile_two)
          player_two ->
            receive_cards(player_one, player_two, play_count + 1, pile_one, card)
        end
      { pid, :cards, cards } ->
        IO.puts "Player #{inspect pid} played #{cards}"
    end

  end

  defp compare({ a, b }) do
    {[ _ | a ], [ _ | b ]} = { a, b }

    compare(a, b)
  end

  defp compare(a, b) when a > b, do: { :winner, :one }
  defp compare(a, b) when a < b, do: { :winner, :two }
  defp compare(a, b), do: { :battle }
  defp compare([], _), do: { :king, :two }
  defp compare(_, []), do: { :king, :one }
end

defmodule Player do
  import IO
  def loop(stack) do
    receive do
      { dealer, :card } ->
        [ head | stack ] = stack
        send dealer, { self, :card, head }
        loop(stack)
      { dealer, :cards } -> puts "Was told to play 3 cards"
      { dealer, :victory, cards } ->
        puts "Won these cards: #{IO.inspect cards}"
        # loop([
      _ -> puts "Whatever"
    end
  end
end
