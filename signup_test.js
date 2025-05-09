const { createClient } = require('@supabase/supabase-js');

// Your Supabase URL and public anon key
const supabaseUrl = 'https://rohfurmgebouerahgvxb.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJvaGZ1cm1nZWJvdWVyYWhndnhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYzNzU0NzIsImV4cCI6MjA2MTk1MTQ3Mn0.8HyxFynBA2UHidiJyWSHhInxopBwBgYyGjSC1fVmOCg';

// Create a Supabase client
const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Test credentials for signup
const email = 'test_user_' + Math.floor(Math.random() * 10000) + '@example.com';
const password = 'TestPassword123\!';

async function signupTest() {
  try {
    console.log('Testing signup with email:', email);
    
    // Attempt to sign up
    const { data, error } = await supabase.auth.signUp({
      email: email,
      password: password,
    });
    
    if (error) {
      console.error('Signup Error:', error);
      return;
    }
    
    console.log('Signup Response:', data);
    console.log('User:', data?.user?.email);
    console.log('Session:', data?.session ? 'Valid' : 'None');
  } catch (e) {
    console.error('Unexpected Error:', e);
  }
}

// Run the test
signupTest();
