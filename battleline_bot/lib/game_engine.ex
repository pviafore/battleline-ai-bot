defmodule GameEngine do

  defmacro __using__(_opts) do
   quote do
     import GameEngine

     @fields []
     @before_compile GameEngine
   end
  end

  defmacro field field_name do
    quote do
      @fields [unquote(field_name) | @fields]
    end
  end

  defmacro action_request field, request

  defmacro __before_compile__(_env) do

    quote do
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
  # I hate how this has unhygenic variables, but this means that you have to have outputter, straetgy and state
  # if I can figure out how to quote a pattern match
  defmacro action_request field, message, val do
    quote do
      send var!(strategy), {unquote(message), var!(outputter), unquote(val)}
      put_in var!(state),[unquote(field)], unquote(val)
    end
  end
end

defmodule BattlelineEngine do
    use GameEngine

    GameEngine.field :direction

    def parse(["player", direction, "name"], outputter, strategy, state), do: action_request(:direction, :player_name, direction)

end
