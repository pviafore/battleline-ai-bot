defmodule DumbStrategy do
   def start outputter do
     {:ok, strategy} = Task.start_link(fn->recv(outputter) end)
     strategy
  end

  def recv outputter do
     receive do
        {:player_name, direction} -> send outputter, {:message, "player " <> direction <> " ElixirBot"}
        {:play_card, _} -> send outputter, {:message, "play 1 b,2"}
        _ -> nil
     end
     recv outputter
  end

end
