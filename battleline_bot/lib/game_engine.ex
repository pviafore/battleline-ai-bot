defmodule GameEngine do

  defmacro __using__(_opts) do
   quote do
     import GameEngine

     @fields []
     @before_compile GameEngine
   end
  end

  defmacro field field_name, initial do
    quote do
      @fields [{unquote(field_name), unquote(initial)} | @fields]
    end
  end


  defmacro __before_compile__(_env) do

    quote do
      defp initial_state, do: (for {field, initial} <- @fields, into: %{}, do: {field, initial} )

      def start strategy do
           {:ok, engine} = Task.start_link(fn->recv( strategy, initial_state) end)
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

       defp recv strategy, state do
          receive do
            {:command, command} ->
               commands = String.split command
               new_state = parse commands, strategy, state
               recv strategy, new_state
            {:state, sender} -> send sender, state
          end
          recv strategy, state
       end
    end
  end
  # I hate how this has unhygenic variables, but this means that you have to have outputter, straetgy and state
  # if I can figure out how to quote a pattern match
  defmacro action_request field, message, val do
    quote do
      send var!(strategy), {unquote(message), unquote(val)}
      simple_update unquote(field), unquote(val)
    end
  end

  defmacro simple_update field, val do
    quote do
      put_in var!(state), [unquote(field)], unquote(val)
    end
  end

  defmacro transform_update field, val, transformer do
    quote do
      put_in var!(state), [unquote(field)], unquote(transformer).(unquote(val))
    end
  end
end

defmodule BattlelineEngine do
    use GameEngine

    GameEngine.field :direction, ""
    GameEngine.field :colors, []
    GameEngine.field :last_move, ""
    GameEngine.field :hand, []
    GameEngine.field :claim, []
    GameEngine.field :flag_cards, [{[],[]},{[],[]},{[],[]},{[],[]},{[],[]},{[],[]},{[],[]},{[],[]},{[],[]}]

    defp make_card [color,number] do
      {color, String.to_integer number}
    end
    defp make_card_from_string card do
      String.split(card, ",")
      |> make_card
    end

    defp update_flag_state flag_cards, "north", cards do
        {cards, elem(flag_cards, 1)}
    end

    defp update_flag_state flag_cards, "south", cards do
        {elem(flag_cards, 0), cards}
    end

    defp update_flag(state) do
       fn {flag, direction, cards} ->
             flag_index = String.to_integer(flag) - 1
             List.replace_at(state.flag_cards, flag_index, update_flag_state(Enum.at(state.flag_cards, flag_index), direction, make_cards_from_string(cards)))
       end
    end

    defp make_cards_from_string(cards), do: Enum.map(cards, &make_card_from_string/1)


    def parse(["player", direction, "name"], strategy, state), do: action_request(:direction, :player_name, direction)
    def parse(["colors", c1, c2, c3, c4, c5, c6], _strategy, state), do: simple_update(:colors, [c1, c2, c3, c4, c5, c6])
    def parse(["player", _direction, "hand" | cards],  _strategy, state), do: transform_update(:hand, cards, &make_cards_from_string/1)
    def parse(["flag", "claim-status", f1, f2, f3, f4, f5, f6, f7, f8, f9], _strategy, state), do: simple_update(:claim, [f1, f2, f3, f4, f5, f6, f7, f8, f9])
    def parse(["opponent", "play", flag, card], _strategy, state), do: simple_update(:last_move, {String.to_integer(flag), make_card_from_string(card)})
    def parse(["go", "play-card"], strategy, state), do: action_request(:play_card, :play_card, state)
    def parse(["flag", flag, "cards", direction | cards], _strategy, state), do: transform_update(:flag_cards, {flag, direction, cards}, update_flag(state))

end
