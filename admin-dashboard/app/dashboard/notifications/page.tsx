'use client';

import { useState, useEffect } from 'react';
import { Bell, Send, Clock, Users, Filter, Plus, History } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { Badge } from '@/components/ui/badge';
import { toast } from 'sonner';

interface NotificationHistory {
  id: string;
  title: string;
  message: string;
  type: string;
  target_type: string;
  recipients_count: number;
  status: string;
  created_at: string;
  profiles: {
    email: string;
    full_name: string;
  };
}

export default function NotificationsPage() {
  const [isOpen, setIsOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const [history, setHistory] = useState<NotificationHistory[]>([]);
  const [loadingHistory, setLoadingHistory] = useState(true);

  // Form state
  const [title, setTitle] = useState('');
  const [message, setMessage] = useState('');
  const [type, setType] = useState('custom');
  const [targetType, setTargetType] = useState('all');
  const [imageUrl, setImageUrl] = useState('');
  const [actionUrl, setActionUrl] = useState('');

  // Fetch notification history
  useEffect(() => {
    fetchHistory();
  }, []);

  const fetchHistory = async () => {
    try {
      const response = await fetch('/api/notifications/history?limit=10');
      if (response.ok) {
        const data = await response.json();
        setHistory(data.notifications);
      }
    } catch (error) {
      console.error('Error fetching history:', error);
    } finally {
      setLoadingHistory(false);
    }
  };

  const handleSendNotification = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const response = await fetch('/api/notifications/send', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          title,
          message,
          type,
          targetType,
          imageUrl: imageUrl || undefined,
          actionUrl: actionUrl || undefined,
        }),
      });

      const data = await response.json();

      if (response.ok) {
        toast.success(`Notification envoyée à ${data.recipients} utilisateurs!`);
        setIsOpen(false);
        // Reset form
        setTitle('');
        setMessage('');
        setType('custom');
        setTargetType('all');
        setImageUrl('');
        setActionUrl('');
        // Refresh history
        fetchHistory();
      } else {
        toast.error(data.error || 'Erreur lors de l\'envoi');
      }
    } catch (error) {
      console.error('Error:', error);
      toast.error('Erreur lors de l\'envoi de la notification');
    } finally {
      setLoading(false);
    }
  };

  const getTypeColor = (type: string) => {
    const colors: Record<string, string> = {
      order_update: 'bg-blue-100 text-blue-800',
      promotion: 'bg-green-100 text-green-800',
      price_drop: 'bg-orange-100 text-orange-800',
      back_in_stock: 'bg-purple-100 text-purple-800',
      custom: 'bg-gray-100 text-gray-800',
    };
    return colors[type] || colors.custom;
  };

  const getStatusColor = (status: string) => {
    const colors: Record<string, string> = {
      sent: 'bg-green-100 text-green-800',
      scheduled: 'bg-yellow-100 text-yellow-800',
      failed: 'bg-red-100 text-red-800',
    };
    return colors[status] || colors.sent;
  };

  return (
    <div className="p-8 max-w-7xl mx-auto">
      {/* Header */}
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-slate-900">Notifications Push</h1>
          <p className="text-slate-600 mt-1">
            Envoyez des notifications à vos utilisateurs
          </p>
        </div>

        <Dialog open={isOpen} onOpenChange={setIsOpen}>
          <DialogTrigger asChild>
            <Button className="bg-black hover:bg-slate-800">
              <Plus className="mr-2 h-4 w-4" />
              Nouvelle notification
            </Button>
          </DialogTrigger>
          <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>Envoyer une notification</DialogTitle>
              <DialogDescription>
                Créez et envoyez une notification push à vos utilisateurs
              </DialogDescription>
            </DialogHeader>

            <form onSubmit={handleSendNotification} className="space-y-6 mt-4">
              {/* Title */}
              <div className="space-y-2">
                <Label htmlFor="title">Titre *</Label>
                <Input
                  id="title"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  placeholder="Ex: Nouvelle promotion !"
                  required
                  maxLength={100}
                />
              </div>

              {/* Message */}
              <div className="space-y-2">
                <Label htmlFor="message">Message *</Label>
                <Textarea
                  id="message"
                  value={message}
                  onChange={(e) => setMessage(e.target.value)}
                  placeholder="Ex: Profitez de -20% sur toutes les pièces de freinage"
                  required
                  rows={3}
                  maxLength={500}
                />
                <p className="text-xs text-slate-500">{message.length}/500 caractères</p>
              </div>

              {/* Type */}
              <div className="space-y-2">
                <Label htmlFor="type">Type de notification</Label>
                <Select value={type} onValueChange={setType}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="custom">Personnalisée</SelectItem>
                    <SelectItem value="promotion">Promotion</SelectItem>
                    <SelectItem value="order_update">Mise à jour commande</SelectItem>
                    <SelectItem value="price_drop">Baisse de prix</SelectItem>
                    <SelectItem value="back_in_stock">Retour en stock</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              {/* Target Audience */}
              <div className="space-y-2">
                <Label htmlFor="targetType">Audience cible</Label>
                <Select value={targetType} onValueChange={setTargetType}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">Tous les utilisateurs</SelectItem>
                    <SelectItem value="segment">Segment spécifique</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              {/* Image URL (Optional) */}
              <div className="space-y-2">
                <Label htmlFor="imageUrl">URL de l'image (optionnel)</Label>
                <Input
                  id="imageUrl"
                  type="url"
                  value={imageUrl}
                  onChange={(e) => setImageUrl(e.target.value)}
                  placeholder="https://example.com/image.jpg"
                />
                <p className="text-xs text-slate-500">
                  Image affichée dans la notification (recommandé: 1200x600px)
                </p>
              </div>

              {/* Action URL (Optional) */}
              <div className="space-y-2">
                <Label htmlFor="actionUrl">URL d'action (optionnel)</Label>
                <Input
                  id="actionUrl"
                  type="url"
                  value={actionUrl}
                  onChange={(e) => setActionUrl(e.target.value)}
                  placeholder="https://bolide.app/products/123"
                />
                <p className="text-xs text-slate-500">
                  Page vers laquelle rediriger lors du clic
                </p>
              </div>

              {/* Actions */}
              <div className="flex gap-3 pt-4">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setIsOpen(false)}
                  className="flex-1"
                >
                  Annuler
                </Button>
                <Button
                  type="submit"
                  disabled={loading || !title || !message}
                  className="flex-1 bg-black hover:bg-slate-800"
                >
                  {loading ? (
                    <>
                      <Clock className="mr-2 h-4 w-4 animate-spin" />
                      Envoi en cours...
                    </>
                  ) : (
                    <>
                      <Send className="mr-2 h-4 w-4" />
                      Envoyer maintenant
                    </>
                  )}
                </Button>
              </div>
            </form>
          </DialogContent>
        </Dialog>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-slate-600">Total envoyées</p>
                <p className="text-2xl font-bold text-slate-900 mt-1">
                  {history.reduce((sum, n) => sum + (n.recipients_count || 0), 0)}
                </p>
              </div>
              <div className="h-12 w-12 bg-blue-100 rounded-full flex items-center justify-center">
                <Send className="h-6 w-6 text-blue-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-slate-600">Notifications</p>
                <p className="text-2xl font-bold text-slate-900 mt-1">{history.length}</p>
              </div>
              <div className="h-12 w-12 bg-green-100 rounded-full flex items-center justify-center">
                <Bell className="h-6 w-6 text-green-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-slate-600">Taux d'envoi</p>
                <p className="text-2xl font-bold text-slate-900 mt-1">100%</p>
              </div>
              <div className="h-12 w-12 bg-purple-100 rounded-full flex items-center justify-center">
                <Users className="h-6 w-6 text-purple-600" />
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Notification History */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <History className="h-5 w-5" />
            Historique des notifications
          </CardTitle>
        </CardHeader>
        <CardContent>
          {loadingHistory ? (
            <div className="text-center py-8 text-slate-500">Chargement...</div>
          ) : history.length === 0 ? (
            <div className="text-center py-12">
              <Bell className="h-12 w-12 text-slate-300 mx-auto mb-4" />
              <p className="text-slate-500">Aucune notification envoyée pour le moment</p>
              <p className="text-sm text-slate-400 mt-1">
                Cliquez sur "Nouvelle notification" pour commencer
              </p>
            </div>
          ) : (
            <div className="space-y-4">
              {history.map((notification) => (
                <div
                  key={notification.id}
                  className="border border-slate-200 rounded-lg p-4 hover:bg-slate-50 transition-colors"
                >
                  <div className="flex items-start justify-between gap-4">
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-2">
                        <h3 className="font-semibold text-slate-900">{notification.title}</h3>
                        <Badge className={getTypeColor(notification.type)}>
                          {notification.type.replace('_', ' ')}
                        </Badge>
                        <Badge className={getStatusColor(notification.status)}>
                          {notification.status}
                        </Badge>
                      </div>
                      <p className="text-sm text-slate-600 mb-3">{notification.message}</p>
                      <div className="flex items-center gap-4 text-xs text-slate-500">
                        <span className="flex items-center gap-1">
                          <Users className="h-3 w-3" />
                          {notification.recipients_count} destinataires
                        </span>
                        <span className="flex items-center gap-1">
                          <Clock className="h-3 w-3" />
                          {new Date(notification.created_at).toLocaleDateString('fr-FR', {
                            day: 'numeric',
                            month: 'short',
                            year: 'numeric',
                            hour: '2-digit',
                            minute: '2-digit',
                          })}
                        </span>
                        {notification.profiles && (
                          <span>
                            Par: {notification.profiles.full_name || notification.profiles.email}
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
