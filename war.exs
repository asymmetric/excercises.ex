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
    # Process.register one, :one
    # Process.register two, :two


    loop([], one, two, [], [])
  end

  defp loop(stack, player_one, player_two, player1_cards, player2_cards) do
    case stack do
      [] ->
        IO.puts "Empty stack, we're in a battle"
        send player_one, { self, :card }
        send player_two, { self, :card }
      _ ->
        IO.puts "The stack in the middle is #{Enum.join(stack, ",")}"
        send player_one, { self, :cards }
        send player_two, { self, :cards }
    end
    [ rank_one, rank_two ] = [ 0, 0 ]
    current_cards = []

    receive do
      { ^player_one, :card, [] } ->
        IO.puts "Player one has lost"
      { ^player_one, :card, val } ->
        IO.puts "Player one played #{val}"
        [ _ | rank_one ] = val
        current_cards = [ val | current_cards ]
      { ^player_one, :cards, vals } ->
        IO.puts "player one played #{vals}"
    end
    receive do
      { ^player_two, :card, [] } ->
        IO.puts "Player two has lost"
      { ^player_two, :card, val } ->
        IO.puts "Player two played #{val}"
        [ _ | rank_two ] = val
        current_cards = [ val | current_cards ]
      { ^player_two, :cards, vals } -> IO.puts "player two played #{vals}"
    end

    cond do
      rank_one > rank_two ->
        send player_one, { self, :victory, current_cards }
        #loop([], player_one, player_two)
      rank_one < rank_two ->
        send player_two, { self, :victory, current_cards }
        #loop([], player_one, player_two)
      rank_one == rank_two ->
        IO.puts "start battle"
        #loop(current_cards, player_one, player_two)
    end
  end

  defp compare(a, b) when a > b do
    IO.puts "give stack to player 1"
  end

  defp compare(a, b) when a < b do
    IO.puts "give stack to player 2"
  end

  defp compare(a, a) do
    # a battle should start
  end

  defp compare([], _) do
    # player 1 has lost
  end

  defp compare(_, []) do
    # player 2 has lost
  end
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
