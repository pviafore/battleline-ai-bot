defmodule ProbStrategy do
   def start outputter do
     {:ok, strategy} = Task.start_link(fn->recv(outputter) end)
     File.open "exout.txt", [:write]
     strategy
  end

  defp get_card_to_play(state) do
     [flag, card, _prob] = GameHelper.get_move(state)
     {:ok, file} = File.open "exout.txt", [:append]
     IO.puts file, "play "<> Integer.to_string(flag + 1) <>" " <> GameHelper.card_to_string(card) <> " " <> Float.to_string(_prob)
     "play "<> Integer.to_string(flag + 1) <>" " <> GameHelper.card_to_string(card)
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




end
