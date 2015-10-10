defmodule GameEngine do

  defp initial_state, do: %{direction: ""}

  def start outputter,strategy do
       {:ok, engine} = Task.start_link(fn->recv(outputter, strategy, initial_state) end)
       engine
   end

   def get_state engine do
       send engine, {:state, self}
       receive do
          m -> {:ok, m}
       end
   end

   def send_command engine,command do
      send engine, {:command, command}
   end

   defp parse ["player", direction, "name"], outputter, strategy, state do
      send strategy, {:player_name, outputter, direction}
      %{ state | direction: direction}
   end

   defp recv outputter, strategy, state do
      receive do
        {:command, command} ->
           commands = String.split command
           new_state = parse commands, outputter, strategy, state
           recv outputter, strategy, new_state
        {:state, sender} -> send sender, state
      end
      recv outputter, strategy, state
   end

end
