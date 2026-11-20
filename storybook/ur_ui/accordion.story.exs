defmodule Storybook.UrUi.Accordion do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.accordion/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :single,
        description: "Single accordion with one item open",
        attributes: %{id: "faq", type: :single, default_value: "billing"},
        slots: [
          ~s|<:trigger value="billing">Billing</:trigger>|,
          ~s|<:trigger value="team">Team</:trigger>|,
          ~s|<:content value="billing">Invoices are issued monthly.</:content>|,
          ~s|<:content value="team">Invite teammates from settings.</:content>|
        ]
      },
      %Variation{
        id: :multiple,
        description: "Multiple accordion with two items open",
        attributes: %{id: "faq-multiple", type: :multiple, default_value: ["billing", "team"]},
        slots: [
          ~s|<:trigger value="billing">Billing</:trigger>|,
          ~s|<:trigger value="team">Team</:trigger>|,
          ~s|<:trigger value="security">Security</:trigger>|,
          ~s|<:content value="billing">Invoices are issued monthly.</:content>|,
          ~s|<:content value="team">Invite teammates from settings.</:content>|,
          ~s|<:content value="security">Password and two-factor authentication.</:content>|
        ]
      },
      %Variation{
        id: :disabled,
        description: "A disabled trigger gets no click command",
        attributes: %{id: "faq-disabled"},
        slots: [
          ~s|<:trigger value="billing">Billing</:trigger>|,
          ~s|<:trigger value="legacy" disabled>Legacy</:trigger>|,
          ~s|<:content value="billing">Invoices are issued monthly.</:content>|,
          ~s|<:content value="legacy">Legacy plans are frozen.</:content>|
        ]
      }
    ]
  end
end
