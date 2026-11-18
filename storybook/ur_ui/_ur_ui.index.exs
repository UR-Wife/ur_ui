defmodule Storybook.UrUi do
  use PhoenixStorybook.Index

  def folder_open?, do: true

  def entry("button"), do: [icon: {:fa, "rectangle-ad", :thin}]
  def entry("badge"), do: [icon: {:fa, "tag", :thin}]
end