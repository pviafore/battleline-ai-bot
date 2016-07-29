defmodule GameHelper do
  import Comb
  def get_highest_card([]), do: nil
  def get_highest_card(cards), do: Enum.max_by cards,&(elem &1, 1)

  def card_to_string({color, number}), do: color <> "," <> Integer.to_string(number)

  def get_enemy("north"), do: "south"
  def get_enemy("south"), do: "north"

  def get_cards(), do: for color <- ["color1", "color2", "color3", "color4", "color5", "color6"], number <- 1..10, do: {color, number}

  defp is_straight(n1,n2,n3) do
     [sn1, sn2, sn3] = Enum.sort [n1,n2,n3]
     sn1 == sn2 - 1 and sn2 == sn3 - 1
  end

  def get_formation_strength([{color, n1}, {color, n2}, {color, n3}]) do
     cond do
         is_straight(n1,n2,n3) -> 500 + n1 + n2 + n3
         true -> 300 + n1 + n2 + n3
     end
  end
  def get_formation_strength([{_, num}, {_, num}, {_, num}]), do: 400 + num*3
  def get_formation_strength([{_, n1}, {_, n2}, {_, n3}]) do
    cond do
        is_straight(n1,n2,n3) -> 200 + n1 + n2 + n3
        true -> 100 + n1 + n2 + n3
    end
  end

  def get_better_formation(f1, f2) do
     Enum.max_by([f1, f2], &get_formation_strength/1)
  end

  def get_highest_formation(existing \\ [],  cards) when is_list(cards) do
      Enum.max_by(get_possibilities(existing, cards), &get_formation_strength/1)
  end

  defp get_possibilities(cards, rest) do
      cards_left = 3 - Enum.count(cards)
      for card_combo <- combinations(rest,cards_left), do: Enum.concat(cards, card_combo)
  end

  defp is_claimed state, flag do
     get_claim(state,flag) != "unclaimed"
  end

  defp get_claim(state, flag), do: Enum.at(state.claim, flag)

  defp get_neighbor_weight(state, index), do: (if state.direction == get_claim(state, index) do 1 else 0 end)

  defp get_neighbor_weight(state, index, :right), do: get_neighbor_weight(state, index + 1) + get_neighbor_weight(state, index+2)
  defp get_neighbor_weight(state, index, :left) ,do: get_neighbor_weight(state, index - 1) + get_neighbor_weight(state, index-2)
  defp get_neighbor_weight(state, index, :both) ,do: get_neighbor_weight(state, index - 1) + get_neighbor_weight(state, index+1)

  defp get_number_of_neighbors(state, 0), do:  get_neighbor_weight(state, 0, :right)
  defp get_number_of_neighbors(state, 1), do:  Enum.max [get_neighbor_weight(state, 1, :right), get_neighbor_weight(state,1, :both)]
  defp get_number_of_neighbors(state, 8), do:  get_neighbor_weight(state, 8, :left)
  defp get_number_of_neighbors(state, 7), do:  Enum.max [get_neighbor_weight(state, 7, :left), get_neighbor_weight(state,1, :both)]
  defp get_number_of_neighbors(state, index), do:  Enum.max [get_neighbor_weight(state, index, :left), get_neighbor_weight(state, index, :right), get_neighbor_weight(state,index, :both)]


  defp get_neighbor_scaled_weight state,index do
      case (get_number_of_neighbors state, index) do
        1 -> 0.15
        2 -> 0.25
        _ -> 0
      end
  end

  defp get_flag_weights state do
    [0.8, 0.9, 1, 1, 1, 1, 1, 0.9, 0.8]
    |> Enum.with_index
    |> Enum.map(fn {elem, index} -> {elem + get_neighbor_scaled_weight(state, index), index} end)
    |> Enum.map(fn {elem, index} -> if is_invalid_flag(state, index) do 0 else elem end end)

  end

  defp is_invalid_flag(state, flag) do
     is_claimed(state,flag) or is_full(state, flag)
  end

  defp is_full(state, flag) do
    length(get_flag_cards(state, state.direction, flag)) == 3
  end

  defp get_flag_cards state, "north", flag do
      elem(Enum.at(state.flag_cards, flag), 0)
  end


  defp get_flag_cards state, "south", flag do
      elem(Enum.at(state.flag_cards, flag), 1)
  end

  defp get_scaled_weight state, {formation, index} do
     get_formation_strength(formation) * Enum.at(get_flag_weights(state), index)
  end

  defp get_highest_formation_on_board state do
      0..8
      |> Enum.map(&{get_highest_formation(get_flag_cards(state, state.direction, &1), state.hand), &1})
      |> Enum.max_by(&(get_scaled_weight(state, &1)))
  end

  def get_playable_flags state do
      0..8
      |> Enum.reject(&is_invalid_flag state, &1)
  end

  def get_plays state do
      cartesian_product(get_playable_flags(state), state.hand)
  end

  def get_played_cards state do
      0..8
      |> Enum.flat_map(&(get_flag_cards(state, "north", &1) ++ get_flag_cards(state, "south", &1)))
  end

  defp get_unplayed_cards state do
      MapSet.difference(MapSet.new(get_cards()), MapSet.new(state.hand ++ get_played_cards(state))) |> MapSet.to_list
  end

  def get_opponent_highest_formation state, flag do
      get_highest_formation(get_flag_cards(state, get_enemy(state.direction), flag), get_unplayed_cards(state)) |> get_formation_strength
  end

  def get_opponent_strengths state do
      0..8
      |> Enum.map(&(get_opponent_highest_formation state, &1))
  end

  def has_more_cards(state, direction, flag) do
      Enum.count(get_flag_cards(state, direction, flag)) >= Enum.count(get_flag_cards(state, get_enemy(direction), flag))
  end

  defp is_stronger state, possibility, opponent_strength,flag do
      strength = get_formation_strength possibility
      strength > opponent_strength or (strength == opponent_strength and has_more_cards(state, state.direction, flag))
  end

  defp get_probability state, possibilities, opponent_strength, flag do
        Enum.count(Enum.filter(possibilities, &(is_stronger state, &1, opponent_strength,flag))) /Enum.count(possibilities)
  end

  def get_play_with_probability state, opponent_strength, [flag, card] do
      possibilities = get_possibilities(get_flag_cards(state, state.direction, flag) ++[card], get_unplayed_cards(state))
      [flag, card, get_probability(state, possibilities, opponent_strength, flag)]
  end


end
