#!/usr/bin/lua

local M = {}

local timeout_ms = vim.g.JdtlsRequestTimeout or 500
local jdtls_name = vim.g.JdtlsName or "jdt.ls"
local bufnr = vim.api.nvim_eval('lighttree#util#get_bufnr_of_filetype("java")') or 0

function M.execute_command(command_params)
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

  local result = vim.lsp.buf_request_sync(bufnr, "workspace/executeCommand", command_params, timeout_ms)
  if result == nil then
    return {}
  end

  local response = {}
  for id, resp in pairs(result) do
    if id == nil then
      print("Error! " .. resp)
    else
      if id == client_id then
        response = resp.result
      else
        print("Could not resolve command " .. command_params.command .. ", jdtls not found.")
      end
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
