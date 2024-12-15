local This = {}

local function get_maven_winbar(filepath, filename)
  local group_id = filepath:match("maven%.groupId=/([^=/]+)")
  local artifact_id = filepath:match("maven%.artifactId=/([^=/]+)")
  local version = filepath:match("maven%.version=/([^=/]+)")
  local packageName = filename:match("%%3C([^%(]+)")
  local className = filename:match("%(([^%.]+%.class)")

  if group_id and artifact_id and version and packageName and className then
    -- Format the winbar with Maven and class details
    return string.format("[%s:%s:%s] %s.%s", group_id, artifact_id, version, packageName, className)
  else
    -- Fallback to filename if parsing fails
    return filename 
  end
end

function This.get_winbar()
  local filepath = vim.fn.expand('%:p')         -- absolute filepath: /home/user/project/folder/file.txt
  local relativeFilepath = vim.fn.expand('%f')  -- relative filepath: folder/file.txt
  local filename = vim.fn.expand('%:t')         -- filename:          file.txt
  if filepath:find("^jdt://") then
    return get_maven_winbar(filepath, filename)
  else
    return relativeFilepath
  end
end


return This
