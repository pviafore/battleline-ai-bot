defmodule ProbStrategy do
   def start outputter do
     {:ok, strategy} = Task.start_link(fn->recv(outputter) end)
     strategy
  end

  defp get_card_to_play(state) do
     {flag, card, _prob} = get_move(state)
     "play "<>flag + 1 <>" " <> GameHelper.card_to_string(card)
  end

  def recv outputter do
     receive do
        {:player_name, direction} -> send outputter, {:message, "player " <> direction <> " ElixirBot"}
        {:play_card, nil} -> IO.puts :stderr, "Who has nil?"
        {:play_card, state} -> send outputter, {:message, get_card_to_play state}
        _ -> nil
     end
     recv outputter
  end

  def get_move state do
      plays = GameHelper.get_plays(state)
      opponents_strength = GameHelper.get_opponent_strengths(state)
      plays = Enum.map(plays, fn [flag, card] ->GameHelper.get_play_with_probability(state, Enum.at(opponents_strength, flag), [flag, card]) end)
      Enum.max_by(plays, &(Enum.at(&1, 2)))

  end

end
