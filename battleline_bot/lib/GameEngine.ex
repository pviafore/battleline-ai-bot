defmodule GameEngine do
  def start do
       {:ok, engine} = Task.start_link(fn->recv() end)
       engine
   end

   def get_state(engine) do
      {:ok, %{}}
   end

   defp recv do

   end

end
