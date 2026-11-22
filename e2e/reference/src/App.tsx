import type { ReactNode } from 'react'
import { variations, type Variation } from '../../shared/variations'
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from '@/components/ui/accordion'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import { Avatar, AvatarBadge, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  Card,
  CardAction,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Separator } from '@/components/ui/separator'
import { Skeleton } from '@/components/ui/skeleton'
import {
  Table,
  TableBody,
  TableCaption,
  TableCell,
  TableFooter,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Textarea } from '@/components/ui/textarea'

function AccordionDemo({ variant }: { variant: string }) {
  const items = variant === 'multiple'
    ? [
        ['billing', 'Billing', 'Invoices are issued monthly.'],
        ['team', 'Team', 'Invite teammates from settings.'],
        ['security', 'Security', 'Password and two-factor authentication.'],
      ]
    : variant === 'disabled'
      ? [
          ['billing', 'Billing', 'Invoices are issued monthly.', false],
          ['legacy', 'Legacy', 'Legacy plans are frozen.', true],
        ]
      : [
          ['billing', 'Billing', 'Invoices are issued monthly.'],
          ['team', 'Team', 'Invite teammates from settings.'],
        ]

  const children = items.map(([value, trigger, content, disabled]) => (
    <AccordionItem key={String(value)} value={String(value)} disabled={Boolean(disabled)}>
      <AccordionTrigger>{trigger}</AccordionTrigger>
      <AccordionContent>{content}</AccordionContent>
    </AccordionItem>
  ))

  if (variant === 'multiple') {
    return <Accordion type="multiple" defaultValue={['billing', 'team']}>{children}</Accordion>
  }
  return (
    <Accordion type="single" defaultValue={variant === 'single' ? 'billing' : undefined} collapsible>
      {children}
    </Accordion>
  )
}

function AlertDemo({ variant }: { variant: string }) {
  return (
    <Alert variant={variant === 'destructive' ? 'destructive' : 'default'}>
      {variant === 'with_icon' && <span data-slot="alert-icon" aria-hidden="true">!</span>}
      <AlertTitle>
        {variant === 'default' && 'Update available'}
        {variant === 'destructive' && 'Unable to delete workspace'}
        {variant === 'with_icon' && 'Heads up'}
        {variant === 'title_only' && 'Changes saved.'}
      </AlertTitle>
      {variant !== 'title_only' && (
        <AlertDescription>
          {variant === 'default' && 'A new version is ready to install.'}
          {variant === 'destructive' && 'Check your permissions and try again.'}
          {variant === 'with_icon' && 'Icons are optional and use the current text colour.'}
        </AlertDescription>
      )}
    </Alert>
  )
}

function AvatarDemo({ variant }: { variant: string }) {
  return (
    <Avatar size={variant === 'sm' ? 'sm' : variant === 'lg' || variant === 'with_badge' ? 'lg' : 'default'}>
      {variant === 'with_image' && <AvatarImage src="/ur_ui_logo.svg" alt="UR" />}
      <AvatarFallback>{variant === 'with_image' ? 'UR' : 'AB'}</AvatarFallback>
      {variant === 'with_badge' && <AvatarBadge>+</AvatarBadge>}
    </Avatar>
  )
}

function ButtonDemo({ variation }: { variation: Variation }) {
  if (variation.variant === 'as_link') {
    return <Button asChild variant="outline"><a href="/save">Save changes</a></Button>
  }
  if (variation.variant === 'disabled') return <Button disabled>Disabled</Button>
  if (variation.variant === 'custom_class') return <Button className="opacity-80">With extra class</Button>

  const size = variation.group === 'sizes' ? variation.variant : 'default'
  const icon = size.startsWith('icon')
  return (
    <Button
      variant={variation.group === 'variants' ? variation.variant as 'default' : 'default'}
      size={size as 'default'}
    >
      {icon ? '★' : variation.group === 'sizes' ? variation.variant === 'default' ? 'Default' : variation.variant.toUpperCase() : variation.variant[0].toUpperCase() + variation.variant.slice(1)}
    </Button>
  )
}

function CardDemo({ variant }: { variant: string }) {
  return (
    <Card className={variant === 'content_only' ? undefined : 'max-w-md'}>
      {variant !== 'content_only' && (
        <CardHeader>
          <CardTitle>
            {variant === 'default' && 'Team members'}
            {variant === 'with_action' && 'Notifications'}
            {variant === 'with_footer' && 'Confirm invitation'}
          </CardTitle>
          {variant !== 'with_footer' && (
            <CardDescription>
              {variant === 'default' ? 'Manage your project team.' : 'Choose what you receive.'}
            </CardDescription>
          )}
          {variant === 'with_action' && <CardAction><Button variant="outline" size="sm">Edit</Button></CardAction>}
        </CardHeader>
      )}
      <CardContent>
        {variant === 'default' && 'Invite and manage collaborators.'}
        {variant === 'with_action' && 'Email notifications are enabled.'}
        {variant === 'with_footer' && 'Accept the invitation to join the workspace.'}
        {variant === 'content_only' && 'A minimal card.'}
      </CardContent>
      {variant === 'with_footer' && <CardFooter><Button>Accept</Button><Button variant="ghost">Decline</Button></CardFooter>}
    </Card>
  )
}

function InputDemo({ variant }: { variant: string }) {
  const error = variant === 'changeset_error' ? 'is invalid' : variant === 'interpolated_error' ? 'should be at least 3 characters' : undefined
  const id = variant === 'changeset_error' ? 'user_email' : variant === 'default' ? 'display-name' : variant === 'interpolated_error' ? 'name' : variant
  const name = variant === 'changeset_error' ? 'user[email]' : variant === 'default' ? 'display_name' : variant
  const value = variant === 'changeset_error' ? 'bad' : variant === 'interpolated_error' ? 'x' : variant === 'disabled' ? 'Read only' : undefined
  const label = {
    default: 'Display name',
    email: 'Email',
    password: 'Password',
    file: 'Picture',
    disabled: 'Disabled',
    changeset_error: 'Email',
    interpolated_error: 'Name',
  }[variant]
  // Mirrors the shadcn docs input-with-label demo.
  return (
    <div className="grid w-full max-w-sm items-center gap-3">
      <Label htmlFor={id}>{label}</Label>
      <div data-slot="input-field">
        <Input
          id={id}
          name={name}
          type={variant === 'email' || variant === 'password' || variant === 'file' ? variant : 'text'}
          placeholder={variant === 'default' ? 'Display name' : variant === 'email' ? 'you@example.com' : undefined}
          required={variant === 'password'}
          accept={variant === 'file' ? 'image/*' : undefined}
          disabled={variant === 'disabled'}
          defaultValue={value}
          aria-invalid={error ? true : undefined}
          aria-describedby={error ? `${id}-errors` : undefined}
        />
        {error && <div id={`${id}-errors`} className="grid gap-1"><p className="text-sm text-destructive" data-slot="input-error">{error}</p></div>}
      </div>
    </div>
  )
}

function TextareaDemo({ variant }: { variant: string }) {
  const error = variant === 'changeset_error' ? 'is invalid' : variant === 'interpolated_error' ? 'should be at least 3 characters' : undefined
  const id = variant === 'changeset_error' ? 'user_bio' : variant === 'default' ? 'bio' : variant === 'interpolated_error' ? 'name' : variant
  const name = variant === 'changeset_error' ? 'user[bio]' : variant === 'default' ? 'bio' : variant
  const value = variant === 'changeset_error' ? 'bad' : variant === 'interpolated_error' ? 'x' : variant === 'disabled' ? 'Read only' : undefined
  const label = {
    default: 'Bio',
    disabled: 'Disabled',
    changeset_error: 'Bio',
    interpolated_error: 'Name',
  }[variant]
  // Mirrors the shadcn docs textarea-with-label demo.
  return (
    <div className="grid w-full max-w-sm items-center gap-3">
      <Label htmlFor={id}>{label}</Label>
      <div data-slot="textarea-field">
        <Textarea
          id={id}
          name={name}
          placeholder={variant === 'default' ? 'Bio' : undefined}
          disabled={variant === 'disabled'}
          defaultValue={value}
          aria-invalid={error ? true : undefined}
          aria-describedby={error ? `${id}-errors` : undefined}
        />
        {error && <div id={`${id}-errors`} className="grid gap-1"><p className="text-sm text-destructive" data-slot="textarea-error">{error}</p></div>}
      </div>
    </div>
  )
}

// Mirrors the shadcn docs separator demo: a horizontal separator under a
// heading block, and a vertical one inside a sized (h-5) flex row.
function SeparatorDemo({ variant }: { variant: string }) {
  if (variant === 'vertical') {
    return (
      <div className="flex h-5 items-center space-x-4 text-sm">
        <div>Blog</div>
        <Separator orientation="vertical" />
        <div>Docs</div>
      </div>
    )
  }
  return (
    <div>
      <div className="space-y-1">
        <h4 className="text-sm leading-none font-medium">Radix Primitives</h4>
        <p className="text-sm text-muted-foreground">An open-source UI component library.</p>
      </div>
      <Separator
        decorative={variant !== 'semantic'}
        className={variant === 'custom_class' ? 'my-4 opacity-80' : 'my-4'}
      />
    </div>
  )
}

function TableDemo({ variant }: { variant: string }) {
  const headings = variant === 'default' ? ['Name', 'Role'] : variant === 'with_footer' ? ['Plan', 'Seats'] : variant === 'selected_row' ? ['Member', 'Status'] : ['Members']
  const rows = variant === 'default'
    ? [['Ada Lovelace', 'Owner'], ['Grace Hopper', 'Editor']]
    : variant === 'with_footer'
      ? [['Team', '8']]
      : variant === 'selected_row'
        ? [['Ada Lovelace', 'Selected']]
        : [['No members found.']]
  return (
    <Table>
      {variant === 'default' && <TableCaption>Workspace members</TableCaption>}
      <TableHeader><TableRow>{headings.map((heading) => <TableHead key={heading}>{heading}</TableHead>)}</TableRow></TableHeader>
      <TableBody>
        {rows.map((row, index) => (
          <TableRow key={row[0]} data-state={variant === 'selected_row' && index === 0 ? 'selected' : undefined}>
            {row.map((cell) => <TableCell key={cell}>{cell}</TableCell>)}
          </TableRow>
        ))}
      </TableBody>
      {variant === 'with_footer' && <TableFooter><TableRow><TableCell>Total</TableCell><TableCell>8</TableCell></TableRow></TableFooter>}
    </Table>
  )
}

function TabsDemo({ variant }: { variant: string }) {
  const values = variant === 'default_value'
    ? [['plans', 'Plans', 'Pick the plan that fits your team.'], ['billing', 'Billing', 'Invoices are issued monthly.']]
    : variant === 'disabled'
      ? [['general', 'General', 'General settings.'], ['advanced', 'Advanced', 'Advanced settings.']]
      : [['general', 'General', 'Manage your profile and contact details.'], ['security', 'Security', 'Password and two-factor authentication.']]
  return (
    <Tabs defaultValue={variant === 'default_value' ? 'billing' : values[0][0]}>
      <TabsList>
        {values.map(([value, label], index) => <TabsTrigger key={value} value={value} disabled={variant === 'disabled' && index === 1}>{label}</TabsTrigger>)}
      </TabsList>
      {values.map(([value, , content]) => <TabsContent key={value} value={value}>{content}</TabsContent>)}
    </Tabs>
  )
}

function Demo({ variation }: { variation: Variation }): ReactNode {
  const { component, variant } = variation
  switch (component) {
    case 'accordion': return <AccordionDemo variant={variant} />
    case 'alert': return <AlertDemo variant={variant} />
    case 'avatar': return <AvatarDemo variant={variant} />
    case 'badge': return <Badge variant={variant === 'custom_class' ? 'default' : variant as 'default'} className={variant === 'custom_class' ? 'opacity-80' : undefined}>{variant === 'custom_class' ? 'With extra class' : variant[0].toUpperCase() + variant.slice(1)}</Badge>
    case 'button': return <ButtonDemo variation={variation} />
    case 'card': return <CardDemo variant={variant} />
    case 'input': return <InputDemo variant={variant} />
    case 'label': return <Label htmlFor={variant === 'with_for' ? 'email' : undefined} className={variant === 'custom_class' ? 'opacity-80' : undefined}>{variant === 'custom_class' ? 'With extra class' : 'Email'}</Label>
    case 'separator': return <SeparatorDemo variant={variant} />
    case 'skeleton': return <Skeleton className={variant === 'custom_class' ? 'h-4 w-[250px] opacity-80' : 'h-4 w-[250px]'} />
    case 'table': return <TableDemo variant={variant} />
    case 'tabs': return <TabsDemo variant={variant} />
    case 'textarea': return <TextareaDemo variant={variant} />
  }
}

export default function App() {
  const variation = variations.find((entry) => entry.route === window.location.pathname)
  if (!variation) return <main><h1>Not found</h1></main>
  const fullWidth = variation.component === 'input' || variation.component === 'textarea' || variation.component === 'table'
  return <main className="p-10"><div data-reference-container data-match-storybook-width={fullWidth || undefined} className={fullWidth ? 'w-full' : 'inline-block'}><Demo variation={variation} /></div></main>
}
