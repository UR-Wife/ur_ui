defmodule Storybook.UrUi do
  use PhoenixStorybook.Index

  def folder_open?, do: true

  def entry("button"), do: [icon: {:fa, "rectangle-ad", :thin}]
  def entry("badge"), do: [icon: {:fa, "tag", :thin}]
  def entry("breadcrumb"), do: [icon: {:fa, "angles-right", :thin}]
  def entry("label"), do: [icon: {:fa, "font", :thin}]
  def entry("separator"), do: [icon: {:fa, "minus", :thin}]
  def entry("skeleton"), do: [icon: {:fa, "square-dashed", :thin}]
  def entry("spinner"), do: [icon: {:fa, "spinner", :thin}]
  def entry("avatar"), do: [icon: {:fa, "circle-user", :thin}]
  def entry("card"), do: [icon: {:fa, "square", :thin}]
  def entry("alert"), do: [icon: {:fa, "bell", :thin}]
  def entry("table"), do: [icon: {:fa, "table", :thin}]
  def entry("input"), do: [icon: {:fa, "keyboard", :thin}]
  def entry("kbd"), do: [icon: {:fa, "keyboard", :thin}]
  def entry("checkbox"), do: [icon: {:fa, "square-check", :thin}]
  def entry("collapsible"), do: [icon: {:fa, "square-caret-down", :thin}]
  def entry("textarea"), do: [icon: {:fa, "align-left", :thin}]
  def entry("tabs"), do: [icon: {:fa, "table-columns", :thin}]
  def entry("toggle"), do: [icon: {:fa, "toggle-on", :thin}]
  def entry("accordion"), do: [icon: {:fa, "square-caret-down", :thin}]
end
