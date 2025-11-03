import { createServerSupabaseClient } from '@/lib/supabase/server'
import { Card, CardContent } from '@/components/ui/card'
import { Bell } from 'lucide-react'

async function getNotifications() {
  const supabase = await createServerSupabaseClient()
  
  const { data: notifications } = await supabase
    .from('notifications')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(50)

  return notifications || []
}

export default async function NotificationsPage() {
  const notifications = await getNotifications()

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-slate-900">Notifications</h1>
        <p className="text-slate-600 mt-1">
          Gérez les notifications de votre application
        </p>
      </div>

      {notifications.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center justify-center py-12">
            <Bell className="h-12 w-12 text-slate-300 mb-4" />
            <p className="text-slate-500">Aucune notification pour le moment</p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-4">
          {notifications.map((notification: any) => (
            <Card key={notification.id}>
              <CardContent className="p-4">
                <div className="flex items-start gap-4">
                  <Bell className="h-5 w-5 text-slate-400 mt-1" />
                  <div className="flex-1">
                    <h3 className="font-medium text-slate-900">{notification.title}</h3>
                    <p className="text-sm text-slate-600 mt-1">{notification.message}</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  )
}
