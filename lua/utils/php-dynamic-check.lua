-- Dynamic PHP compatibility checking using PHP's built-in parser
local M = {}

-- Function to get PHP binary path
local function get_php_binary()
  -- Try to find PHP binary
  local php_paths = {
    vim.fn.exepath("php"),
    "/usr/bin/php",
    "/usr/local/bin/php",
    "/opt/homebrew/bin/php",
  }
  
  for _, path in ipairs(php_paths) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end
  
  return nil
end

-- Check PHP code using PHP's parser with specific version
function M.check_compatibility(bufnr, target_version)
  local php_binary = get_php_binary()
  if not php_binary then
    vim.notify("PHP binary not found", vim.log.levels.ERROR)
    return {}
  end
  
  local diagnostics = {}
  local temp_file = vim.fn.tempname() .. ".php"
  
  -- Get buffer content
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  vim.fn.writefile(lines, temp_file)
  
  -- Create a PHP script to check syntax with version-specific features
  local check_script = [[
<?php
// Set error reporting to catch all issues
error_reporting(E_ALL);
ini_set('display_errors', '1');

// Target PHP version
$targetVersion = ']] .. target_version .. [[';
$targetVersionId = (int)str_replace('.', '', $targetVersion) * 100;

// Get actual PHP version for comparison
$currentVersionId = PHP_VERSION_ID;

// Read the file to check
$file = ']] .. temp_file .. [[';
$content = file_get_contents($file);

// First, check basic syntax
$output = shell_exec('php -l ' . escapeshellarg($file) . ' 2>&1');
if (strpos($output, 'No syntax errors') === false) {
    // Extract line number from syntax error
    if (preg_match('/on line (\d+)/', $output, $matches)) {
        echo json_encode(array(
            'line' => (int)$matches[1],
            'message' => trim(str_replace('Parse error:', '', $output)),
            'type' => 'syntax'
        ));
        exit(0);
    }
}

// Check for version-specific features using token analysis
$tokens = token_get_all($content);
$errors = array();

// Track current line number
$currentLine = 1;

for ($i = 0; $i < count($tokens); $i++) {
    $token = $tokens[$i];
    
    if (is_array($token)) {
        list($id, $text, $line) = $token;
        $currentLine = $line;
        
        // Check for specific tokens and features
        switch ($id) {
            case T_STRING:
                // Check function calls
                $nextToken = $tokens[$i + 1] ?? null;
                if (is_array($nextToken) && $nextToken[0] === T_WHITESPACE) {
                    $nextToken = $tokens[$i + 2] ?? null;
                }
                
                if ($nextToken === '(') {
                    // This is a function call
                    $funcName = $text;
                    
                    // Check if function exists in target version
                    if (function_exists($funcName)) {
                        $ref = new ReflectionFunction($funcName);
                        $ext = $ref->getExtension();
                        
                        // Special checks for version-specific functions
                        $versionSpecificFuncs = array(
                            'str_contains' => 80000,
                            'str_starts_with' => 80000,
                            'str_ends_with' => 80000,
                            'array_key_first' => 70300,
                            'array_key_last' => 70300,
                            'is_countable' => 70300,
                            'hrtime' => 70300,
                            'fdiv' => 80000,
                            'get_debug_type' => 80000,
                            'get_resource_id' => 80000,
                            'preg_last_error_msg' => 80000,
                        );
                        
                        if (isset($versionSpecificFuncs[$funcName]) && $targetVersionId < $versionSpecificFuncs[$funcName]) {
                            $errors[] = array(
                                'line' => $currentLine,
                                'message' => sprintf("Function '%s' requires PHP %s or later (target: PHP %s)", 
                                    $funcName, 
                                    number_format($versionSpecificFuncs[$funcName] / 10000, 1),
                                    $targetVersion
                                ),
                                'type' => 'compatibility'
                            );
                        }
                    }
                }
                break;
                
            case T_MATCH:
                if ($targetVersionId < 80000) {
                    $errors[] = array(
                        'line' => $currentLine,
                        'message' => "Match expression requires PHP 8.0 or later (target: PHP $targetVersion)",
                        'type' => 'compatibility'
                    );
                }
                break;
                
            case T_FN:
                if ($targetVersionId < 70400) {
                    $errors[] = array(
                        'line' => $currentLine,
                        'message' => "Arrow functions (fn) require PHP 7.4 or later (target: PHP $targetVersion)",
                        'type' => 'compatibility'
                    );
                }
                break;
                
            case T_NULLSAFE_OBJECT_OPERATOR:
                if ($targetVersionId < 80000) {
                    $errors[] = array(
                        'line' => $currentLine,
                        'message' => "Nullsafe operator (?->) requires PHP 8.0 or later (target: PHP $targetVersion)",
                        'type' => 'compatibility'
                    );
                }
                break;
                
            case T_ATTRIBUTE:
                if ($targetVersionId < 80000) {
                    $errors[] = array(
                        'line' => $currentLine,
                        'message' => "Attributes (#[...]) require PHP 8.0 or later (target: PHP $targetVersion)",
                        'type' => 'compatibility'
                    );
                }
                break;
                
            case T_READONLY:
                if ($targetVersionId < 80100) {
                    $errors[] = array(
                        'line' => $currentLine,
                        'message' => "Readonly properties require PHP 8.1 or later (target: PHP $targetVersion)",
                        'type' => 'compatibility'
                    );
                }
                break;
                
            case T_ENUM:
                if ($targetVersionId < 80100) {
                    $errors[] = array(
                        'line' => $currentLine,
                        'message' => "Enums require PHP 8.1 or later (target: PHP $targetVersion)",
                        'type' => 'compatibility'
                    );
                }
                break;
        }
    }
}

echo json_encode($errors);
]]
  
  -- Write check script to temp file
  local check_script_file = vim.fn.tempname() .. "_check.php"
  vim.fn.writefile(vim.split(check_script, "\n"), check_script_file)
  
  -- Run the check script
  local cmd = string.format("%s %s 2>&1", php_binary, check_script_file)
  local output = vim.fn.system(cmd)
  
  -- Parse output
  local ok, result = pcall(vim.fn.json_decode, output)
  if ok and type(result) == "table" then
    for _, error in ipairs(result) do
      table.insert(diagnostics, {
        lnum = error.line - 1,
        col = 0,
        severity = error.type == "syntax" and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
        message = error.message,
        source = "php-version",
      })
    end
  end
  
  -- Clean up temp files
  vim.fn.delete(temp_file)
  vim.fn.delete(check_script_file)
  
  return diagnostics
end

-- Setup function
function M.setup(target_version)
  if not target_version then
    return
  end
  
  local ns = vim.api.nvim_create_namespace("php_dynamic_diagnostics")
  
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged", "InsertLeave" }, {
    pattern = "*.php",
    callback = function(args)
      vim.schedule(function()
        local diagnostics = M.check_compatibility(args.buf, target_version)
        vim.diagnostic.set(ns, args.buf, diagnostics)
        
        if #diagnostics > 0 then
          local compat_issues = 0
          for _, d in ipairs(diagnostics) do
            if d.source == "php-version" and d.severity == vim.diagnostic.severity.WARN then
              compat_issues = compat_issues + 1
            end
          end
          
          if compat_issues > 0 then
            vim.notify(
              string.format("%d PHP %s compatibility issue%s. Press <leader>xp to view.", 
                compat_issues, 
                target_version,
                compat_issues > 1 and "s" or ""),
              vim.log.levels.WARN
            )
          end
        end
      end)
    end,
  })
end

return M