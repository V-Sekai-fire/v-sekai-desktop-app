defmodule TodoApp.MenuBar do
  @moduledoc """
    Menubar that is shown as part of the main Window on Windows/Linux. In
    MacOS this Menubar appears at the very top of the screen.
  """
  import TodoWeb.Gettext
  use Desktop.Menu
  alias TodoApp.Todo
  alias Desktop.Window

  def render(assigns) do
    ~H"""
    <menubar>
    <menu label={gettext "File"}>
        <item onclick="todo"><%= gettext "Todo" %></item>
        <%= for item <- @todos do %>
        <item
            type="checkbox" onclick={"toggle:#{item.id}"}
            checked={item.status == "done"}
            ><%= item.text %></item>
        <% end %>
        <hr/>
        <item onclick="quit"><%= gettext "Quit" %></item>
    </menu>
    <menu label={gettext "Task"}>
        <item onclick="edit"><%= gettext "Edit Tasks" %></item>
    </menu>
    <menu label={gettext "Extra"}>
        <item onclick="notification"><%= gettext "Show Notification" %></item>
        <item onclick="observer"><%= gettext "Show Observer" %></item>
    </menu>
    </menubar>
    """
  end

  def handle_event(<<"toggle:", id::binary>>, menu) do
    Todo.toggle_todo(String.to_integer(id))
    {:noreply, menu}
  end

  def handle_event("observer", menu) do
    :observer.start()
    {:noreply, menu}
  end

  def handle_event("quit", menu) do
    Window.quit()
    {:noreply, menu}
  end

  def handle_event("todo", menu) do
    Window.show(TodoWindow, Window.prepare_url(TodoWeb.Endpoint.url() <> "/"))
    {:noreply, menu}
  end

  def handle_event("edit", menu) do
    Window.show(TodoWindow, Window.prepare_url(TodoWeb.Endpoint.url() <> "/admin"))
    {:noreply, menu}
  end

  def handle_event("notification", menu) do
    Window.show_notification(TodoWindow, gettext("Sample Elixir Desktop App!"),
      callback: &TodoWeb.TodoLive.notification_event/1
    )

    {:noreply, menu}
  end

  def mount(menu) do
    TodoApp.Todo.subscribe()
    {:ok, assign(menu, todos: Todo.all_todos())}
  end

  def handle_info(:changed, menu) do
    {:noreply, assign(menu, todos: Todo.all_todos())}
  end
end
