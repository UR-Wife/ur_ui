export const components = [
  'accordion',
  'alert',
  'avatar',
  'badge',
  'breadcrumb',
  'button',
  'card',
  'checkbox',
  'input',
  'kbd',
  'label',
  'separator',
  'skeleton',
  'spinner',
  'table',
  'tabs',
  'toggle',
  'textarea',
] as const

export type ComponentName = (typeof components)[number]
export type Theme = 'light' | 'dark'

export interface Variation {
  component: ComponentName
  variant: string
  route: string
  storyId: string
  storyPath: string
  group?: 'variants' | 'sizes'
  screenshotSlot?: 'input-field' | 'table-container' | 'textarea-field'
}

const slug = (value: string) => value.replaceAll('_', '-')

function grouped(
  component: ComponentName,
  group: 'variants' | 'sizes',
  variants: string[],
): Variation[] {
  return variants.map((variant) => ({
    component,
    variant,
    group,
    route: `/${component}/${component === 'button' && group === 'sizes' ? 'size-' : ''}${slug(variant)}`,
    storyId: `${component}-${group}-${variant}`,
    storyPath: `/storybook/ur_ui/${component}`,
  }))
}

function single(component: ComponentName, variants: string[]): Variation[] {
  return variants.map((variant) => ({
    component,
    variant,
    route: `/${component}/${slug(variant)}`,
    storyId: `${component}-single-${slug(variant)}`,
    storyPath: `/storybook/ur_ui/${component}`,
    screenshotSlot:
      component === 'input' && variant.includes('error')
        ? 'input-field'
        : component === 'textarea' && variant.includes('error')
          ? 'textarea-field'
          : component === 'table'
            ? 'table-container'
            : undefined,
  }))
}

export const variations: Variation[] = [
  ...grouped('accordion', 'variants', []),
  ...single('accordion', ['single', 'multiple', 'disabled']),
  ...single('alert', ['default', 'destructive', 'with_icon', 'title_only']),
  ...grouped('avatar', 'sizes', ['default', 'sm', 'lg']),
  ...single('avatar', ['with_image', 'with_badge']),
  ...grouped('badge', 'variants', ['default', 'secondary', 'destructive', 'outline', 'ghost', 'link']),
  ...single('badge', ['custom_class']),
  ...single('breadcrumb', ['default', 'with_ellipsis']),
  ...grouped('button', 'variants', ['default', 'destructive', 'outline', 'secondary', 'ghost', 'link']),
  ...grouped('button', 'sizes', ['default', 'xs', 'sm', 'lg', 'icon', 'icon-xs', 'icon-sm', 'icon-lg']),
  ...single('button', ['as_link', 'disabled', 'custom_class']),
  ...single('card', ['default', 'with_action', 'with_footer', 'content_only']),
  ...single('checkbox', ['default', 'checked', 'disabled']),
  ...single('input', ['default', 'email', 'password', 'file', 'disabled', 'changeset_error', 'interpolated_error']),
  ...single('kbd', ['default', 'custom_class']),
  ...single('label', ['default', 'with_for', 'custom_class']),
  ...single('separator', ['horizontal', 'vertical', 'semantic', 'custom_class']),
  ...single('skeleton', ['default', 'custom_class']),
  ...single('spinner', ['default', 'custom_class']),
  ...single('table', ['default', 'with_footer', 'selected_row', 'empty']),
  ...single('tabs', ['default', 'default_value', 'disabled']),
  ...single('toggle', ['default', 'pressed', 'outline', 'disabled']),
  ...single('textarea', ['default', 'disabled', 'changeset_error', 'interpolated_error']),
]

export function variationKey(variation: Variation): string {
  return [variation.component, variation.group, variation.variant].filter(Boolean).join('/')
}
