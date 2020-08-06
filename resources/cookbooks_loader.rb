resource_name :cookbooks_loader
provides :cookbooks_loader

property :directory, String, name_property: true
property :organization, String, required: true

action :load do
  cookbooks_dir = new_resource.directory
  organization = new_resource.organization

  return if cookbooks_dir.nil? || !Dir.exist?(cookbooks_dir)

  configrb = "#{node['mcs']['managed']['dir']}/#{organization}/config.rb"
  configjson = "#{node['mcs']['managed']['dir']}/#{organization}/config.json"

  cookbooks_temp_dir = Chef::Config[:file_cache_path] + '/mcs-cookbooks'
  # create a temp dir for untarring the cookbooks
  Dir.mkdir(cookbooks_temp_dir) unless Dir.exist?(cookbooks_temp_dir)

  # iterate over the files in the cookbooks directory, Berks first
  Dir.foreach(cookbooks_dir) do |tarfile|
    next unless tarfile.end_with?('.tgz', '.tar.gz')

    untarred_dir = "#{cookbooks_temp_dir}/#{tarfile.sub(/.tgz$|.tar.gz$/, '')}"
    untarred_marker = untarred_dir + '-TAR'
    # untar into temp directory named after the tarball
    unless ::File.exist?(untarred_marker)
      Dir.mkdir(untarred_dir) # create a temp dir for each tarball
      shell_out!("tar -C #{untarred_dir} -xzf #{cookbooks_dir}/#{tarfile}") # untar to directory
      shell_out!("touch #{untarred_marker}") # marker file indicating not to untar again
    end

    berks_marker = untarred_dir + '-BERKS'
    berksfile = "#{untarred_dir}/#{untarred_dir.split('/').last}/Berksfile"
    if ::File.exist?(berksfile)
      bash "berks install/upload #{tarfile}" do
        cwd untarred_dir
        code <<-EOH
berks install -b #{berksfile} -c #{configjson}
berks upload -b #{berksfile} -c #{configjson}
touch #{berks_marker}
        EOH
        not_if { ::File.exist?(berks_marker) }
      end
    end
  end

  # iterate over the files in the cookbooks directory, knife loop
  Dir.foreach(cookbooks_dir) do |tarfile|
    next unless tarfile.end_with?('.tgz', '.tar.gz')

    untarred_dir = "#{cookbooks_temp_dir}/#{tarfile.sub(/.tgz$|.tar.gz$/, '')}"
    knife_marker = untarred_dir + '-KNIFE'
    berksfile = "#{untarred_dir}/#{untarred_dir.split('/').last}/Berksfile"

    unless ::File.exist?(berksfile)
      # try knife cookbook upload. This could take multiple passes given dependencies
      bash "knife cookbook upload #{tarfile}" do
        cwd untarred_dir
        code <<-EOH
knife cookbook upload -a -c #{configrb} -o #{untarred_dir}
touch #{knife_marker}
        EOH
        ignore_failure true
        not_if { ::File.exist?(knife_marker) }
      end
    end
  end
end
