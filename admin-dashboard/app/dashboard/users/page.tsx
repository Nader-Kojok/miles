import { createServerSupabaseClient } from '@/lib/supabase/server'
import { UsersTable } from './users-table'
import { Card, CardContent } from '@/components/ui/card'

async function getUsers() {
  const supabase = await createServerSupabaseClient()
  
  const { data: profiles, error } = await supabase
    .from('profiles')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) {
    console.error('Error fetching users:', error)
    return []
  }

  return profiles || []
}

async function getUserStats() {
  const supabase = await createServerSupabaseClient()
  
  const { count: totalUsers } = await supabase
    .from('profiles')
    .select('*', { count: 'exact', head: true })

  const { data: recentUsers } = await supabase
    .from('profiles')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(5)

  return {
    totalUsers: totalUsers || 0,
    recentUsers: recentUsers || [],
  }
}

export default async function UsersPage() {
  const [users, stats] = await Promise.all([getUsers(), getUserStats()])

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-slate-900">Utilisateurs</h1>
        <p className="text-slate-600 mt-1">
          Gérez les utilisateurs de votre application
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <Card>
          <CardContent className="pt-6">
            <div className="text-sm font-medium text-slate-600">Total utilisateurs</div>
            <div className="text-3xl font-bold text-slate-900 mt-2">
              {stats.totalUsers}
            </div>
          </CardContent>
        </Card>
      </div>

      <UsersTable users={users} />
    </div>
  )
}
