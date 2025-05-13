# Resistance Task Manager

A revolutionary task management system for Neovim, themed around Palestinian resistance and solidarity.

## ✊ Features

- Task categories representing different forms of resistance
- Revolutionary task tracking and reporting
- Solidarity-themed task notifications
- Integration with Neovim workflow

## 🚀 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "alqattandev/resistance-taskmanager.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "rcarriga/nvim-notify",
  },
  config = true,
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  "alqattandev/resistance-taskmanager.nvim",
  requires = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "rcarriga/nvim-notify",
  },
  config = function()
    require("resistance-taskmanager").setup()
  end
}
```

## ⚙️ Configuration

```lua
require("resistance-taskmanager").setup({
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
})
```

## 🔑 Commands

- `:ResistanceTaskAdd` - Add a new revolutionary task
- `:ResistanceTaskView` - View your resistance tasks
- `:ResistanceReport` - Generate a resistance progress report

## ⌨️ Keymaps

No default keymaps are provided. Here are some suggested mappings:

```lua
vim.keymap.set("n", "<leader>rta", require("resistance-taskmanager").add_task, { desc = "Add Resistance Task" })
vim.keymap.set("n", "<leader>rtv", require("resistance-taskmanager").view_tasks, { desc = "View Resistance Tasks" })
vim.keymap.set("n", "<leader>rtr", require("resistance-taskmanager").generate_report, { desc = "Resistance Task Report" })
```

## 🌱 Philosophy

This plugin embodies the spirit of resistance through steadfastness (صمود) in daily coding tasks. By integrating Palestinian resistance themes into your workflow, it serves as a constant reminder of solidarity and the ongoing struggle for justice.

## 📜 License

MIT