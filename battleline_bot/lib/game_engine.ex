defmodule GameEngine do

  defmacro __using__(_opts) do
   quote do
     import GameEngine

     @fields []
     @action_requests []
     @before_compile GameEngine
   end
  end

  defmacro action_request field_name, request, pattern do
    quote do
      @fields [unquote(field_name) | @fields]
      @action_requests [{unquote(field_name), unquote(request), unquote(pattern)} | @action_requests]
    end
  end

  defmacro __before_compile__(env) do
    quote do

      for req <- @action_requests do
        def parse ["player", direction, "name"], outputter, strategy, state do
           send strategy, {:player_name, outputter, direction}
           %{ state | direction: direction}
        end
      end

      defp initial_state, do: (for field <- @fields, into: %{}, do: {field, ""} )



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
  end
end

defmodule BattlelineEngine do
    use GameEngine

    GameEngine.action_request :direction, :a, :b
end
