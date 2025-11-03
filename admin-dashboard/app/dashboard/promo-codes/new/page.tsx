import { PromoCodeForm } from '../promo-code-form'

export default function NewPromoCodePage() {
  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-slate-900">Nouveau code promo</h1>
        <p className="text-slate-600 mt-1">
          Créez un nouveau code promotionnel pour vos clients
        </p>
      </div>

      <PromoCodeForm />
    </div>
  )
}
