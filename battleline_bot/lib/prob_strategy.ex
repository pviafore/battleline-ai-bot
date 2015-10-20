defmodule ProbStrategy do
   def start outputter do
     {:ok, strategy} = Task.start_link(fn->recv(outputter) end)
     strategy
  end

  defp get_card_to_play(state) do
     "play 1 " <> GameHelper.card_to_string({"b", 2})
  end

  def recv outputter do
     receive do
        {:player_name, direction} -> send outputter, {:message, "player " <> direction <> " ElixirBot"}
        {:play_card, state} -> send outputter, {:message, get_card_to_play state}
        _ -> nil
     end
     recv outputter
  end

end
