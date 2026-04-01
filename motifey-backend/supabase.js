const { createClient } = require("@supabase/supabase-js");

const supabase = createClient(
  "https://xyfdsaighjmiiketlhep.supabase.co",
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh5ZmRzYWlnaGptaWlrZXRsaGVwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUwMDkzNTgsImV4cCI6MjA5MDU4NTM1OH0.Cz-zINbGslhUSolqfO0XqTZR9gojICXfNxg9bRfDCd4"
);

module.exports = supabase;