defmodule RvAppHardware.Led do
  require Logger

  alias Circuits.GPIO

  @led_pin Application.get_env(:rv_app_hardware, :led_pin, 18)

  def switch_power() do
    GPIO.write(output_gpio(), 1 - GPIO.read(output_gpio()))
    |> broadcast(:power_switched)
  end

  def state do
    case GPIO.read(output_gpio()) do
      0 -> "off"
      1 -> "on"
    end
  end

  def subscribe do
    Phoenix.PubSub.subscribe(RvAppUi.PubSub, "power")
  end

  defp output_gpio do
    {:ok, output_gpio} = GPIO.open(@led_pin, :output)
    output_gpio
  end

  defp broadcast(:ok, event) do
    Phoenix.PubSub.broadcast(RvAppUi.PubSub, "power", {event, state()})
    {:ok, state()}
  end
end
