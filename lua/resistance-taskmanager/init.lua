-- Resistance Task Manager
-- A revolutionary task management system for coding with purpose

local Path = require("plenary.path")
local nui_popup = require("nui.popup")
local nui_menu = require("nui.menu")
local nui_input = require("nui.input")
local notify = require("notify")

-- Create the namespace
local taskmanager = {}

-- Default configuration
local default_config = {
  -- Task categories
  categories = {
    { id = "sumud", name = "Steadfastness (صمود)", color = "#007A3D", icon = "🌿" },
    { id = "intifada", name = "Rising Up (انتفاضة)", color = "#CE1126", icon = "✊" },
    { id = "thawra", name = "Revolution (ثورة)", color = "#000000", icon = "⚡" },
    { id = "awda", name = "Return (عودة)", color = "#FFFFFF", icon = "🗝️" },
    { id = "hurriya", name = "Freedom (حرية)", color = "#FFD700", icon = "🕊️" },
  },
  
  -- Notification settings
  notifications = {
    enabled = true,
    frequency = 0.2, -- Chance of showing solidarity message on task completion
  },
  
  -- Storage settings
  storage = {
    path = vim.fn.stdpath("data") .. "/resistance_tasks.json",
  },
}

-- Plugin configuration
local config = {}

-- File to store the tasks
local tasks_file = nil

-- Initialize tasks
local tasks = {}

-- Save tasks to file
local function save_tasks()
  tasks_file:write(vim.fn.json_encode(tasks), "w")
end

-- Load tasks from file
local function load_tasks()
  if tasks_file:exists() then
    local content = tasks_file:read()
    if content and content ~= "" then
      local ok, data = pcall(vim.fn.json_decode, content)
      if ok then
        tasks = data
      end
    end
  else
    -- Create empty tasks file
    save_tasks()
  end
end

-- Generate a unique ID for a new task
local function generate_id()
  local highest_id = 0
  for _, task in ipairs(tasks) do
    if tonumber(task.id) > highest_id then
      highest_id = tonumber(task.id)
    end
  end
  return tostring(highest_id + 1)
end

-- Show solidarity message
local function show_solidarity_message()
  local messages = {
    "✊ Your coding is an act of resistance!",
    "🇵🇸 From the river to the sea, Palestine will be free!",
    "🌿 Steadfastness (صمود) in coding and in life!",
    "⚡ Revolution begins with small acts of resistance!",
    "🗝️ Never forget the right of return!",
    "🕊️ Coding for justice and liberation!",
  }
  
  local message = messages[math.random(#messages)]
  notify(message, vim.log.levels.INFO, {
    title = "💪 SOLIDARITY 💪",
    timeout = 3000,
  })
end

-- Daily solidarity notification
function taskmanager.daily_solidarity()
  local cities = {
    "Gaza", "Ramallah", "Nablus", "Jenin", "Hebron", "Bethlehem", 
    "Jericho", "Tulkarm", "Qalqilya", "Rafah", "Khan Yunis", "Jabalia",
    "Jerusalem", "Haifa", "Jaffa", "Acre", "Nazareth", "Beersheba",
    "Safad", "Tiberias", "Lydda", "Ramle", "Majdal", "Deir al-Balah", 
    "Lifta", "Deir Yassin", "Al-Majdal", "Ein Houd"
  }
  
  local city = cities[math.random(#cities)]
  local message = "🇵🇸 Remember " .. city .. " today as you code in solidarity"
  
  notify(message, vim.log.levels.INFO, {
    title = "Daily Solidarity",
    timeout = 5000,
  })
end

-- Add a new task
function taskmanager.add_task()
  -- Create input popup for task title
  local title_input = nui_input({
    position = "50%",
    size = {
      width = 60,
      height = 2,
    },
    border = {
      style = "rounded",
      text = {
        top = " ✊ New Resistance Task ",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal",
    },
  }, {
    prompt = "Title: ",
    default_value = "",
    on_submit = function(title)
      if title and title ~= "" then
        -- Create category selection menu
        local menu_items = {}
        for _, category in ipairs(config.categories) do
          table.insert(menu_items, nui_menu.item(category.icon .. " " .. category.name, { id = category.id }))
        end
        
        local category_menu = nui_menu({
          position = "50%",
          size = {
            width = 60,
            height = #menu_items + 2,
          },
          border = {
            style = "rounded",
            text = {
              top = " Select Category ",
              top_align = "center",
            },
          },
          win_options = {
            winhighlight = "Normal:Normal",
          },
        }, {
          lines = menu_items,
          max_width = 60,
          keymap = {
            focus_next = { "j", "<Down>" },
            focus_prev = { "k", "<Up>" },
            close = { "<Esc>", "<C-c>" },
            submit = { "<CR>" },
          },
          on_submit = function(item)
            -- Create description input
            local desc_input = nui_input({
              position = "50%",
              size = {
                width = 60,
                height = 2,
              },
              border = {
                style = "rounded",
                text = {
                  top = " Task Description ",
                  top_align = "center",
                },
              },
              win_options = {
                winhighlight = "Normal:Normal",
              },
            }, {
              prompt = "Description: ",
              default_value = "",
              on_submit = function(description)
                -- Create the task
                local new_task = {
                  id = generate_id(),
                  title = title,
                  description = description or "",
                  category = item.id,
                  status = "pending",
                  created_at = os.time(),
                  updated_at = os.time(),
                }
                
                table.insert(tasks, new_task)
                save_tasks()
                
                -- Show confirmation
                notify("✊ Task added: " .. title, vim.log.levels.INFO, {
                  title = "Resistance Task Manager",
                  timeout = 3000,
                })
                
                -- Show solidarity message occasionally
                if config.notifications.enabled and math.random() < config.notifications.frequency then
                  show_solidarity_message()
                end
              end,
            })
            
            desc_input:mount()
          end,
        })
        
        category_menu:mount()
      end
    end,
  })
  
  title_input:mount()
end

-- View tasks
function taskmanager.view_tasks()
  if #tasks == 0 then
    notify("No resistance tasks found. Add some with :ResistanceTaskAdd", vim.log.levels.INFO, {
      title = "Resistance Task Manager",
      timeout = 3000,
    })
    return
  end
  
  -- Create menu items for tasks
  local menu_items = {}
  for _, task in ipairs(tasks) do
    -- Find category
    local category = nil
    for _, cat in ipairs(config.categories) do
      if cat.id == task.category then
        category = cat
        break
      end
    end
    
    local icon = category and category.icon or "✓"
    local status_icon = task.status == "done" and "✓" or "⬜"
    
    table.insert(menu_items, nui_menu.item(
      status_icon .. " " .. icon .. " " .. task.title,
      { id = task.id }
    ))
  end
  
  local tasks_menu = nui_menu({
    position = "50%",
    size = {
      width = 70,
      height = math.min(#menu_items + 2, 20),
    },
    border = {
      style = "rounded",
      text = {
        top = " 🇵🇸 Resistance Tasks ",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal",
    },
  }, {
    lines = menu_items,
    max_width = 70,
    keymap = {
      focus_next = { "j", "<Down>" },
      focus_prev = { "k", "<Up>" },
      close = { "<Esc>", "<C-c>" },
      submit = { "<CR>" },
    },
    on_submit = function(item)
      -- Find the task
      local selected_task = nil
      for _, task in ipairs(tasks) do
        if task.id == item.id then
          selected_task = task
          break
        end
      end
      
      if selected_task then
        -- Create action menu
        local action_items = {
          nui_menu.item("✓ Mark as Done", { action = "done" }),
          nui_menu.item("⬜ Mark as Pending", { action = "pending" }),
          nui_menu.item("✏️ Edit Task", { action = "edit" }),
          nui_menu.item("🗑️ Delete Task", { action = "delete" }),
        }
        
        local action_menu = nui_menu({
          position = "50%",
          size = {
            width = 40,
            height = #action_items + 2,
          },
          border = {
            style = "rounded",
            text = {
              top = " Task Actions ",
              top_align = "center",
            },
          },
          win_options = {
            winhighlight = "Normal:Normal",
          },
        }, {
          lines = action_items,
          max_width = 40,
          keymap = {
            focus_next = { "j", "<Down>" },
            focus_prev = { "k", "<Up>" },
            close = { "<Esc>", "<C-c>" },
            submit = { "<CR>" },
          },
          on_submit = function(action_item)
            if action_item.action == "done" then
              selected_task.status = "done"
              selected_task.updated_at = os.time()
              save_tasks()
              notify("✓ Task marked as done: " .. selected_task.title, vim.log.levels.INFO, {
                title = "Resistance Task Manager",
                timeout = 3000,
              })
              
              -- Show solidarity message occasionally
              if config.notifications.enabled and math.random() < config.notifications.frequency then
                show_solidarity_message()
              end
            elseif action_item.action == "pending" then
              selected_task.status = "pending"
              selected_task.updated_at = os.time()
              save_tasks()
              notify("⬜ Task marked as pending: " .. selected_task.title, vim.log.levels.INFO, {
                title = "Resistance Task Manager",
                timeout = 3000,
              })
            elseif action_item.action == "delete" then
              -- Find and remove the task
              for i, task in ipairs(tasks) do
                if task.id == selected_task.id then
                  table.remove(tasks, i)
                  break
                end
              end
              save_tasks()
              notify("🗑️ Task deleted: " .. selected_task.title, vim.log.levels.INFO, {
                title = "Resistance Task Manager",
                timeout = 3000,
              })
            elseif action_item.action == "edit" then
              -- Create edit popup
              local edit_input = nui_input({
                position = "50%",
                size = {
                  width = 60,
                  height = 2,
                },
                border = {
                  style = "rounded",
                  text = {
                    top = " Edit Task Title ",
                    top_align = "center",
                  },
                },
                win_options = {
                  winhighlight = "Normal:Normal",
                },
              }, {
                prompt = "Title: ",
                default_value = selected_task.title,
                on_submit = function(new_title)
                  if new_title and new_title ~= "" then
                    -- Update description
                    local desc_input = nui_input({
                      position = "50%",
                      size = {
                        width = 60,
                        height = 2,
                      },
                      border = {
                        style = "rounded",
                        text = {
                          top = " Edit Task Description ",
                          top_align = "center",
                        },
                      },
                      win_options = {
                        winhighlight = "Normal:Normal",
                      },
                    }, {
                      prompt = "Description: ",
                      default_value = selected_task.description or "",
                      on_submit = function(new_description)
                        selected_task.title = new_title
                        selected_task.description = new_description
                        selected_task.updated_at = os.time()
                        save_tasks()
                        
                        notify("✏️ Task updated: " .. new_title, vim.log.levels.INFO, {
                          title = "Resistance Task Manager",
                          timeout = 3000,
                        })
                      end,
                    })
                    
                    desc_input:mount()
                  end
                end,
              })
              
              edit_input:mount()
            end
          end,
        })
        
        action_menu:mount()
      end
    end,
  })
  
  tasks_menu:mount()
end

-- Generate a report of resistance tasks
function taskmanager.generate_report()
  if #tasks == 0 then
    notify("No resistance tasks found. Add some with :ResistanceTaskAdd", vim.log.levels.INFO, {
      title = "Resistance Task Manager",
      timeout = 3000,
    })
    return
  end
  
  -- Count tasks by category and status
  local stats = {
    total = #tasks,
    done = 0,
    pending = 0,
    categories = {},
  }
  
  for _, task in ipairs(tasks) do
    -- Count by status
    if task.status == "done" then
      stats.done = stats.done + 1
    else
      stats.pending = stats.pending + 1
    end
    
    -- Count by category
    if not stats.categories[task.category] then
      stats.categories[task.category] = {
        total = 0,
        done = 0,
        pending = 0,
      }
    end
    
    stats.categories[task.category].total = stats.categories[task.category].total + 1
    if task.status == "done" then
      stats.categories[task.category].done = stats.categories[task.category].done + 1
    else
      stats.categories[task.category].pending = stats.categories[task.category].pending + 1
    end
  end
  
  -- Create report content
  local report = {
    "🇵🇸 RESISTANCE TASK REPORT 🇵🇸",
    "--------------------------------",
    "",
    "Total Tasks: " .. stats.total,
    "Completed: " .. stats.done .. " (" .. math.floor(stats.done / stats.total * 100) .. "%)",
    "Pending: " .. stats.pending .. " (" .. math.floor(stats.pending / stats.total * 100) .. "%)",
    "",
    "BY CATEGORY:",
    "-----------",
  }
  
  for _, category in ipairs(config.categories) do
    local cat_stats = stats.categories[category.id]
    if cat_stats then
      local cat_line = category.icon .. " " .. category.name .. ": " .. cat_stats.total .. " tasks"
      if cat_stats.total > 0 then
        cat_line = cat_line .. " (" .. cat_stats.done .. " done, " .. cat_stats.pending .. " pending)"
      end
      table.insert(report, cat_line)
    end
  end
  
  -- Add solidarity message
  table.insert(report, "")
  table.insert(report, "✊ SOLIDARITY IN ACTION ✊")
  table.insert(report, "Your coding is an act of resistance!")
  
  -- Create popup with report
  local report_popup = nui_popup({
    position = "50%",
    size = {
      width = 70,
      height = #report + 2,
    },
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = " Resistance Report ",
        top_align = "center",
      },
    },
    buf_options = {
      modifiable = false,
      readonly = true,
    },
    win_options = {
      winhighlight = "Normal:Normal",
    },
  })
  
  report_popup:mount()
  
  -- Set content
  vim.api.nvim_buf_set_lines(report_popup.bufnr, 0, -1, false, report)
  
  -- Close on any key
  report_popup:map("n", "<Esc>", function()
    report_popup:unmount()
  end, { noremap = true })
  
  report_popup:map("n", "q", function()
    report_popup:unmount()
  end, { noremap = true })
  
  report_popup:map("n", "<CR>", function()
    report_popup:unmount()
  end, { noremap = true })
  
  -- Show solidarity message
  if config.notifications.enabled then
    show_solidarity_message()
  end
end

-- Setup function
function taskmanager.setup(user_config)
  -- Merge user config with defaults
  config = vim.tbl_deep_extend("force", default_config, user_config or {})
  
  -- Initialize tasks file
  tasks_file = Path:new(config.storage.path)
  
  -- Load tasks
  load_tasks()
  
  -- Register commands
  vim.api.nvim_create_user_command("ResistanceTaskAdd", taskmanager.add_task, {})
  vim.api.nvim_create_user_command("ResistanceTaskView", taskmanager.view_tasks, {})
  vim.api.nvim_create_user_command("ResistanceReport", taskmanager.generate_report, {})
  
  -- Daily solidarity notification on startup
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      -- Delay to show after dashboard
      vim.defer_fn(function()
        taskmanager.daily_solidarity()
      end, 1500)
    end,
  })
  
  return taskmanager
end

return taskmanager