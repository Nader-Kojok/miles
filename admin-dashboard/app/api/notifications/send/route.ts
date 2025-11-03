import { NextRequest, NextResponse } from 'next/server';
import { createServerSupabaseClient } from '@/lib/supabase/server';

const ONESIGNAL_APP_ID = process.env.ONESIGNAL_APP_ID!;
const ONESIGNAL_REST_API_KEY = process.env.ONESIGNAL_REST_API_KEY!;

export async function POST(request: NextRequest) {
  try {
    const supabase = await createServerSupabaseClient();

    // Check if user is admin
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { data: profile } = await supabase
      .from('profiles')
      .select('is_admin')
      .eq('id', user.id)
      .single();

    if (!profile?.is_admin) {
      return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
    }

    // Parse request body
    const body = await request.json();
    const {
      title,
      message,
      type = 'custom',
      targetType = 'all', // 'all', 'specific', 'segment'
      userIds = [],
      segment = 'Subscribed Users',
      data = {},
      scheduledFor,
      imageUrl,
      actionUrl,
    } = body;

    // Validate required fields
    if (!title || !message) {
      return NextResponse.json(
        { error: 'Title and message are required' },
        { status: 400 }
      );
    }

    // Build OneSignal notification payload
    const oneSignalPayload: any = {
      app_id: ONESIGNAL_APP_ID,
      headings: { en: title },
      contents: { en: message },
      data: {
        type,
        ...data,
      },
    };

    // Set target audience
    if (targetType === 'all') {
      oneSignalPayload.included_segments = ['Subscribed Users'];
    } else if (targetType === 'specific' && userIds.length > 0) {
      oneSignalPayload.include_aliases = {
        external_id: userIds,
      };
      oneSignalPayload.target_channel = 'push';
    } else if (targetType === 'segment') {
      oneSignalPayload.included_segments = [segment];
    }

    // Add optional fields
    if (imageUrl) {
      oneSignalPayload.big_picture = imageUrl;
      oneSignalPayload.ios_attachments = { id: imageUrl };
    }

    if (actionUrl) {
      oneSignalPayload.url = actionUrl;
    }

    // Schedule notification if specified
    if (scheduledFor) {
      const scheduledDate = new Date(scheduledFor);
      oneSignalPayload.send_after = scheduledDate.toISOString();
    }

    // Send notification via OneSignal API
    const oneSignalResponse = await fetch('https://onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${ONESIGNAL_REST_API_KEY}`,
      },
      body: JSON.stringify(oneSignalPayload),
    });

    const oneSignalResult = await oneSignalResponse.json();

    if (!oneSignalResponse.ok) {
      console.error('OneSignal error:', oneSignalResult);
      return NextResponse.json(
        { error: 'Failed to send notification', details: oneSignalResult },
        { status: 500 }
      );
    }

    // Save notification to database for history
    const { data: savedNotification, error: dbError } = await supabase
      .from('admin_notifications')
      .insert({
        title,
        message,
        type,
        target_type: targetType,
        target_user_ids: targetType === 'specific' ? userIds : null,
        target_segment: targetType === 'segment' ? segment : null,
        image_url: imageUrl,
        action_url: actionUrl,
        scheduled_for: scheduledFor,
        onesignal_id: oneSignalResult.id,
        sent_by: user.id,
        status: scheduledFor ? 'scheduled' : 'sent',
        recipients_count: oneSignalResult.recipients || 0,
      })
      .select()
      .single();

    if (dbError) {
      console.error('Database error:', dbError);
    }

    return NextResponse.json({
      success: true,
      notificationId: oneSignalResult.id,
      recipients: oneSignalResult.recipients,
      savedNotification,
    });
  } catch (error) {
    console.error('Error sending notification:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
