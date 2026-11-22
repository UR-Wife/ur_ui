defmodule UrUi.AvatarTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UrUi.Components

  @avatar_base "group/avatar relative flex size-8 shrink-0 overflow-hidden rounded-full select-none data-[size=lg]:size-10 data-[size=sm]:size-6"
  @image_base "aspect-square size-full"
  @fallback_base "flex size-full items-center justify-center rounded-full bg-muted text-sm text-muted-foreground group-data-[size=sm]/avatar:text-xs [[data-slot=avatar-image]:not([hidden])~&]:hidden"
  @badge_base "absolute right-0 bottom-0 z-10 inline-flex items-center justify-center rounded-full bg-primary text-primary-foreground ring-2 ring-background select-none group-data-[size=sm]/avatar:size-2 group-data-[size=sm]/avatar:[&>svg]:hidden group-data-[size=default]/avatar:size-2.5 group-data-[size=default]/avatar:[&>svg]:size-2 group-data-[size=lg]/avatar:size-3 group-data-[size=lg]/avatar:[&>svg]:size-2"
  @group_base "group/avatar-group flex -space-x-2 *:data-[slot=avatar]:ring-2 *:data-[slot=avatar]:ring-background"
  @count_base "relative flex size-8 shrink-0 items-center justify-center rounded-full bg-muted text-sm text-muted-foreground ring-2 ring-background group-has-data-[size=lg]/avatar-group:size-10 group-has-data-[size=sm]/avatar-group:size-6 [&>svg]:size-4 group-has-data-[size=lg]/avatar-group:[&>svg]:size-5 group-has-data-[size=sm]/avatar-group:[&>svg]:size-3"

  defp render_avatar(assigns), do: render_component(&Components.avatar/1, assigns)
  defp render_image(assigns), do: render_component(&Components.avatar_image/1, assigns)
  defp render_fallback(assigns), do: render_component(&Components.avatar_fallback/1, assigns)
  defp render_badge(assigns), do: render_component(&Components.avatar_badge/1, assigns)
  defp render_group(assigns), do: render_component(&Components.avatar_group/1, assigns)
  defp render_count(assigns), do: render_component(&Components.avatar_group_count/1, assigns)

  defp inner(content),
    do: %{__slot__: :inner_block, inner_block: fn _changed, _arg -> content end}

  defp assert_classes(html, slot, base, custom \\ nil) do
    expected = [base, custom] |> Enum.reject(&is_nil/1) |> Enum.join(" ")
    [avatar] = Floki.parse_fragment!(html) |> Floki.find("[data-slot='#{slot}']")
    assert Floki.attribute(avatar, "class") == [expected]
  end

  describe "avatar root" do
    test "defaults to :default size with classes and marker" do
      html = render_avatar(%{inner_block: inner("AB")})
      assert_classes(html, "avatar", @avatar_base)
      assert html =~ ~s(data-size="default")
    end

    test "size :sm renders sm classes and marker" do
      html = render_avatar(%{size: :sm, inner_block: inner("AB")})
      assert_classes(html, "avatar", @avatar_base)
      assert html =~ ~s(data-size="sm")
    end

    test "size :lg renders lg classes and marker" do
      html = render_avatar(%{size: :lg, inner_block: inner("AB")})
      assert_classes(html, "avatar", @avatar_base)
      assert html =~ ~s(data-size="lg")
    end

    test "renders without any attrs at all" do
      html = render_avatar(%{})
      assert_classes(html, "avatar", @avatar_base)
    end

    test "class extends base classes" do
      html = render_avatar(%{class: "ring-2", inner_block: inner("AB")})
      assert_classes(html, "avatar", @avatar_base, "ring-2")
    end

    test "global attributes pass through" do
      html = render_avatar(%{id: "a1", inner_block: inner("AB")})
      assert html =~ ~s(id="a1")
    end
  end

  describe "avatar_image" do
    test "renders img with src and alt" do
      html = render_image(%{id: "i1", src: "/u.png", alt: "Ada"})
      assert html =~ "<img"
      assert html =~ ~s(src="/u.png")
      assert html =~ ~s(alt="Ada")
      assert_classes(html, "avatar-image", @image_base)
    end

    test "alt defaults to empty string" do
      html = render_image(%{id: "i1", src: "/u.png"})
      assert html =~ ~s(alt="")
    end

    test "uses the UrUiAvatarImage hook on the caller's stable id" do
      html = render_image(%{src: "/u.png", id: "ada-photo"})
      [img] = html |> Floki.parse_fragment!() |> Floki.find("img")
      assert Floki.attribute(img, "id") == ["ada-photo"]
      assert Floki.attribute(img, "phx-hook") == ["UrUiAvatarImage"]
      refute html =~ "<script"
    end

    test "class extends base classes" do
      html = render_image(%{id: "i1", src: "/u.png", class: "grayscale"})
      assert_classes(html, "avatar-image", @image_base, "grayscale")
    end
  end

  describe "avatar_fallback" do
    test "renders span with content" do
      html = render_fallback(%{inner_block: inner("AB")})
      assert html =~ "<span"
      assert_classes(html, "avatar-fallback", @fallback_base)
      assert html =~ "AB"
    end

    test "class extends base classes" do
      html = render_fallback(%{class: "text-xs", inner_block: inner("AB")})
      assert_classes(html, "avatar-fallback", @fallback_base, "text-xs")
    end
  end

  describe "avatar_badge" do
    test "renders span with content" do
      html = render_badge(%{inner_block: inner("*")})
      assert html =~ "<span"
      assert_classes(html, "avatar-badge", @badge_base)
      assert html =~ "*"
    end
  end

  describe "avatar_group" do
    test "renders div with content" do
      html = render_group(%{inner_block: inner("x")})
      assert html =~ "<div"
      assert_classes(html, "avatar-group", @group_base)
      assert html =~ "x"
    end
  end

  describe "avatar_group_count" do
    test "renders div with content" do
      html = render_count(%{inner_block: inner("+3")})
      assert_classes(html, "avatar-group-count", @count_base)
      assert html =~ "+3"
    end
  end
end
