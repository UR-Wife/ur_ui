defmodule Storybook.UrUi.Tabs do
  use PhoenixStorybook.Story, :component

  def function, do: &UrUi.Components.tabs/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :default,
        description: "Two tabs, first one selected",
        attributes: %{id: "account-tabs"},
        slots: [
          ~s|<:trigger value="general">General</:trigger>|,
          ~s|<:trigger value="security">Security</:trigger>|,
          ~s|<:content value="general">Manage your profile and contact details.</:content>|,
          ~s|<:content value="security">Password and two-factor authentication.</:content>|
        ]
      },
      %Variation{
        id: :default_value,
        description: "A default_value opens that tab on load",
        attributes: %{id: "billing-tabs", default_value: "billing"},
        slots: [
          ~s|<:trigger value="plans">Plans</:trigger>|,
          ~s|<:trigger value="billing">Billing</:trigger>|,
          ~s|<:content value="plans">Pick the plan that fits your team.</:content>|,
          ~s|<:content value="billing">Invoices are issued monthly.</:content>|
        ]
      },
      %Variation{
        id: :disabled,
        description: "A disabled trigger stays unfocusable",
        attributes: %{id: "disabled-tabs"},
        slots: [
          ~s|<:trigger value="general">General</:trigger>|,
          ~s|<:trigger value="advanced" disabled>Advanced</:trigger>|,
          ~s|<:content value="general">General settings.</:content>|,
          ~s|<:content value="advanced">Advanced settings.</:content>|
        ]
      }
    ]
  end
end
