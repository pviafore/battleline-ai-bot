defmodule GameHelper do
  import Comb
  def get_highest_card([]), do: nil
  def get_highest_card(cards), do: Enum.max_by cards,&(elem &1, 1)

  def card_to_string({color, number}), do: color <> "," <> Integer.to_string(number)

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
      cards_left = 3 - Enum.count(existing)
      card_possibilities = for card_combo <- combinations(cards,cards_left), do: Enum.concat(existing, card_combo)
      Enum.max_by(card_possibilities, &get_formation_strength/1)
  end

  defp is_claimed state, flag do
     Enum.at(state.claim, flag) != "unclaimed"
  end

  defp get_flag_weights state do
    [0.8, 0.9, 1, 1, 1, 1, 1, 0.9, 0.8]
    |> Enum.with_index
    |> Enum.map fn {elem, index} -> if is_invalid_flag(state, index) do 0 else elem end end
  end

  defp is_invalid_flag(state, flag) do
     is_claimed(state,flag) or is_full(state, flag)
  end

  defp is_full(state, flag) do
    length(get_flag_cards(state, state.direction, flag)) == 3
  end

  defp get_flag_cards state, :north, flag do
      elem(Enum.at(state.flag_cards, flag), 0)
  end


  defp get_flag_cards state, :south, flag do
      elem(Enum.at(state.flag_cards, flag), 1)
  end

  defp get_flag state do
     flag_weights = get_flag_weights state
     Enum.find_index(flag_weights, &(&1 == Enum.max(flag_weights)))
  end

  defp get_scaled_weight state, {formation, index} do
     get_formation_strength(formation) * Enum.at(get_flag_weights(state), index)
  end

  defp get_highest_formation_on_board state do
      0..8
      |> Enum.map(&{get_highest_formation(get_flag_cards(state, state.direction, &1), state.hand), &1})
      |> Enum.max_by &(get_scaled_weight(state, &1))
  end

  def get_move state do
      {formation, flag} = get_highest_formation_on_board(state)
      {flag, get_highest_card formation}
  end

end
