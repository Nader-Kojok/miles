import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

export default function SettingsPage() {
  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-slate-900">Paramètres</h1>
        <p className="text-slate-600 mt-1">
          Configurez les paramètres de votre application
        </p>
      </div>

      <div className="max-w-3xl space-y-6">
        <Card>
          <CardHeader>
            <CardTitle>Informations de la boutique</CardTitle>
            <CardDescription>
              Gérez les informations de votre boutique
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label htmlFor="store_name">Nom de la boutique</Label>
              <Input
                id="store_name"
                placeholder="Bolide Pièces Auto"
                defaultValue="Bolide"
              />
            </div>
            <div>
              <Label htmlFor="store_phone">Téléphone</Label>
              <Input
                id="store_phone"
                placeholder="+221 77 123 45 67"
                defaultValue="+221"
              />
            </div>
            <div>
              <Label htmlFor="store_email">Email</Label>
              <Input
                id="store_email"
                type="email"
                placeholder="contact@bolide.sn"
              />
            </div>
            <div>
              <Label htmlFor="store_address">Adresse</Label>
              <Input
                id="store_address"
                placeholder="Dakar, Sénégal"
              />
            </div>
            <Button>Enregistrer les modifications</Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Notifications</CardTitle>
            <CardDescription>
              Configurez les notifications de l&apos;application
            </CardDescription>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-slate-600">
              Configuration des notifications disponible prochainement.
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Paiement</CardTitle>
            <CardDescription>
              Configurez les méthodes de paiement
            </CardDescription>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-slate-600">
              Intégrations Orange Money et Wave à venir.
            </p>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
