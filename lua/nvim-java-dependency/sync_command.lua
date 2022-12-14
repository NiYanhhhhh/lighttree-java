#!/usr/bin/lua
local M = {}

local timeout_ms = vim.g.lighttree_java_request_timeout or 500
local jdtls_name = vim.g.lighttree_java_server_name or "jdtls"
local bufnr = vim.api.nvim_eval('lighttree#util#get_bufnr_of_filetype("java")') or 0

local function check_params(params)
  for k, v in pairs(params) do
    if type(k) == "boolean" then
      params[k] = nil
    end
    if type(v) == "table" then
      check_params(v)
    end
  end
  return params
end

function M.execute_command(command_params)
  -- print(vim.inspect(command_params))
  local client_id = -1
  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if client.name == jdtls_name then
      client_id = client.id
    end
  end
  if client_id == -1 then
    print("Could not resolve command " .. command_params.command .. ", jdtls not found.")
    return {}
  end

  if not vim.fn.bufloaded(vim.fn.bufname(bufnr)) then
    bufnr = vim.api.nvim_eval('lighttree#util#get_bufnr_of_filetype("java")') or 0
  end
  check_params(command_params)
  local result = vim.lsp.buf_request_sync(bufnr, "workspace/executeCommand", command_params, timeout_ms)
  if result == nil then
    return {}
  end

  local response = {}
  for id, resp in pairs(result) do
    if id == client_id then
      if resp.error then
        print("Error! ".. resp.error.message)
      else
        response = resp.result
      end
    else
      print("Could not resolve command " .. command_params.command .. ", jdtls not found.")
    end
  end
  if response == nil then
    response = {}
  end
  return response
end

function M.get_projects(arg)
  local command = {command = "java.project.list", arguments = arg}
  local resp = M.execute_command(command)
  return resp
end

function M.resolve_path(arg)
  local command = {command = "java.resolvePath", arguments = arg}
  local resp = M.execute_command(command)
  return resp
end

function M.get_package_data(arg)
  local command = {command = "java.getPackageData", arguments = arg}
  local resp = M.execute_command(command)
  return resp
end

return M
