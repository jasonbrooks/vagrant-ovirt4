describe command('uname -a') do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should be_empty }
  its(:stdout) { should match(/^Linux dynamic-[a-f0-9\-]+/) }
end

