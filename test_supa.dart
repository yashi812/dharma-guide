import 'package:supabase/supabase.dart'; 
void main() async { 
  final client = SupabaseClient('https://bklyszfnaebbpkxlmilw.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJrbHlzemZuYWViYnBreGxtaWx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0NTI5MDQsImV4cCI6MjA5MTAyODkwNH0.z14EBElS6PeTZQOHkoVLYdPebjIUigRLeHdd4X6bI2I'); 
  try { 
    await client.from('manifestation_journals').upsert({'user_id': '00000000-0000-0000-0000-000000000000', 'technique_name': 'test', 'journal_text': 'test', 'journaled_on': '2025-01-01'}, onConflict: 'user_id,technique_name,journaled_on'); 
    print('Success'); 
  } catch(e) { 
    print('Error: $e'); 
  } 
}
