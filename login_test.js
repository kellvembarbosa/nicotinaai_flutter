const { createClient } = require('@supabase/supabase-js');

// Your Supabase URL and public anon key
const supabaseUrl = 'https://rohfurmgebouerahgvxb.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJvaGZ1cm1nZWJvdWVyYWhndnhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYzNzU0NzIsImV4cCI6MjA2MTk1MTQ3Mn0.8HyxFynBA2UHidiJyWSHhInxopBwBgYyGjSC1fVmOCg';

// Create a Supabase client
const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Test credentials
const email = 'kellvem222@gmail.com';
const password = '123123123';

async function loginTest() {
  try {
    console.log('Testing login with credentials:', email);
    
    // Attempt to sign in
    const { data, error } = await supabase.auth.signInWithPassword({
      email: email,
      password: password,
    });
    
    if (error) {
      console.error('Login Error:', error);
      return;
    }
    
    console.log('Login Successful\!');
    console.log('User:', data?.user?.email);
    console.log('Session:', data?.session ? 'Valid' : 'None');
  } catch (e) {
    console.error('Unexpected Error:', e);
  }
}

// Run the test
loginTest();
