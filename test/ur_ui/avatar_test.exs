defmodule UrUi.AvatarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  defp render_avatar(assigns), do: render_component(&Components.avatar/1, assigns)
  defp render_image(assigns), do: render_component(&Components.avatar_image/1, assigns)
  defp render_fallback(assigns), do: render_component(&Components.avatar_fallback/1, assigns)
  defp render_badge(assigns), do: render_component(&Components.avatar_badge/1, assigns)
  defp render_group(assigns), do: render_component(&Components.avatar_group/1, assigns)
  defp render_count(assigns), do: render_component(&Components.avatar_group_count/1, assigns)

  defp inner(content),
    do: %{__slot__: :inner_block, inner_block: fn _changed, _arg -> content end}

  describe "avatar root" do
    test "defaults to :default size with classes and marker" do
      html = render_avatar(%{inner_block: inner("AB")})
      assert html =~ "ur-avatar"
      assert html =~ "ur-avatar--size-default"
      assert html =~ ~s(data-size="default")
    end

    test "size :sm renders sm classes and marker" do
      html = render_avatar(%{size: :sm, inner_block: inner("AB")})
      assert html =~ "ur-avatar--size-sm"
      assert html =~ ~s(data-size="sm")
    end

    test "size :lg renders lg classes and marker" do
      html = render_avatar(%{size: :lg, inner_block: inner("AB")})
      assert html =~ "ur-avatar--size-lg"
      assert html =~ ~s(data-size="lg")
    end

    test "renders without any attrs at all" do
      html = render_avatar(%{})
      assert html =~ "ur-avatar"
    end

    test "class extends base classes" do
      html = render_avatar(%{class: "ring-2", inner_block: inner("AB")})
      assert html =~ "ur-avatar"
      assert html =~ "ring-2"
    end

    test "global attributes pass through" do
      html = render_avatar(%{id: "a1", inner_block: inner("AB")})
      assert html =~ ~s(id="a1")
    end
  end

  describe "avatar_image" do
    test "renders img with src and alt" do
      html = render_image(%{src: "/u.png", alt: "Ada"})
      assert html =~ "<img"
      assert html =~ ~s(src="/u.png")
      assert html =~ ~s(alt="Ada")
      assert html =~ "ur-avatar__image"
    end

    test "alt defaults to empty string" do
      html = render_image(%{src: "/u.png"})
      assert html =~ ~s(alt="")
    end

    test "class extends base classes" do
      html = render_image(%{src: "/u.png", class: "grayscale"})
      assert html =~ "ur-avatar__image"
      assert html =~ "grayscale"
    end
  end

  describe "avatar_fallback" do
    test "renders span with content" do
      html = render_fallback(%{inner_block: inner("AB")})
      assert html =~ "<span"
      assert html =~ "ur-avatar__fallback"
      assert html =~ "AB"
    end

    test "class extends base classes" do
      html = render_fallback(%{class: "text-xs", inner_block: inner("AB")})
      assert html =~ "ur-avatar__fallback"
      assert html =~ "text-xs"
    end
  end

  describe "avatar_badge" do
    test "renders span with content" do
      html = render_badge(%{inner_block: inner("*")})
      assert html =~ "<span"
      assert html =~ "ur-avatar__badge"
      assert html =~ "*"
    end
  end

  describe "avatar_group" do
    test "renders div with content" do
      html = render_group(%{inner_block: inner("x")})
      assert html =~ "<div"
      assert html =~ "ur-avatar-group"
      assert html =~ "x"
    end
  end

  describe "avatar_group_count" do
    test "renders div with content" do
      html = render_count(%{inner_block: inner("+3")})
      assert html =~ "ur-avatar-group__count"
      assert html =~ "+3"
    end
  end
end
