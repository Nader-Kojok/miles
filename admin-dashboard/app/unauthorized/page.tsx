import Link from 'next/link'
import { ShieldAlert } from 'lucide-react'
import { Button } from '@/components/ui/button'

export default function UnauthorizedPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800">
      <div className="max-w-md w-full mx-4">
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-xl p-8 text-center">
          <div className="flex justify-center mb-6">
            <div className="rounded-full bg-red-100 dark:bg-red-900/20 p-4">
              <ShieldAlert className="h-12 w-12 text-red-600 dark:text-red-400" />
            </div>
          </div>
          
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-4">
            Accès non autorisé
          </h1>
          
          <p className="text-gray-600 dark:text-gray-300 mb-8">
            Vous n&apos;avez pas les permissions nécessaires pour accéder au tableau de bord administrateur. 
            Seuls les administrateurs peuvent accéder à cette section.
          </p>

          <div className="space-y-3">
            <p className="text-sm text-gray-500 dark:text-gray-400">
              Si vous pensez qu&apos;il s&apos;agit d&apos;une erreur, veuillez contacter votre administrateur système.
            </p>
            
            <Button asChild className="w-full">
              <Link href="/login">
                Retour à la connexion
              </Link>
            </Button>
          </div>
        </div>
      </div>
    </div>
  )
}
