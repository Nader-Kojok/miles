import { Sidebar } from '@/components/sidebar'
import { isAdmin } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  // Server-side admin check as additional security layer
  const userIsAdmin = await isAdmin()
  
  if (!userIsAdmin) {
    redirect('/unauthorized')
  }

  return (
    <div className="flex h-screen overflow-hidden bg-gray-50">
      <Sidebar />
      <main className="flex-1 overflow-y-auto">
        {children}
      </main>
    </div>
  )
}
