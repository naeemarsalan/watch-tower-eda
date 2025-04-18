# Watch Tower (EDA/AAP)

**Watch Tower** is an Event-Driven Ansible (EDA)-based monitoring and automation framework designed to monitor an external PostgreSQL database and dynamically scale Ansible Automation Platform (AAP) components. Rather than building and managing a traditional Kubernetes Operator, this project leverages Ansible EDA rulebooks and PostgreSQL's `pg_notify` feature to create a more flexible and event-driven approach.

## Purpose

This project serves as an alternative to writing a custom Kubernetes Operator by using Ansible's Event-Driven Automation capabilities. Its primary goal is to watch the role of an external EDB PostgreSQL database—whether it is operating as a **primary** or **standby**—and respond accordingly. When a promotion or failover event occurs (e.g., standby becomes primary), Watch Tower takes action by scaling AAP's `automationcontroller` appropriately.

## Architecture Overview

The system is composed of the following key components:

1. **pg_trigger_check.yml**:  
   A rulebook that runs on an interval using the `tick` source plugin. It acts like a Kubernetes controller loop, periodically checking if the PostgreSQL trigger exists. If not, it runs a job template to:
   - Create a trigger function in the database.
   - Use `pg_notify` to emit events on insert.
   
2. **pg_monitor_rulebook.yml**, **pg_monitor_rulebook_site1.yml**, **pg_monitor_rulebook_site2.yml**:  
   These rulebooks use the `pg_listener` source to listen to `pg_notify` messages from the database. When a notification is received, they determine if the database role has changed to `primary` or `standby` and run corresponding job templates to scale AAP.

3. **Ansible Job Templates**:
   - Scale up or down AAP’s automation controller depending on whether the database is in a primary or standby role.

## Flow Summary

1. The `pg_trigger_check.yml` rulebook periodically runs and ensures the PostgreSQL trigger is in place.
2. If the trigger is missing, it executes a job template that:
   - Creates the `pg_notify` trigger function.
   - Adds the trigger to the `queue.message` table.
3. The database now emits a notification to a specific channel (`text`) when an insert occurs.
4. The `pg_monitor_rulebook*.yml` rulebooks listen on the channel.
5. When a notification is received (indicating role change or insert), the rulebook evaluates the event:
   - If the role is `primary`, it scales up the Automation Controller.
   - If the role is not `primary`, it scales it down.
6. The system continues to monitor and respond in real time to changes in the PostgreSQL role.

## Technologies Used

- Ansible Rulebooks / Event-Driven Ansible
- Red Hat Ansible Automation Platform (AAP)
- External EDB PostgreSQL
- pg_notify (PostgreSQL built-in notification system)
- Tick source plugin (EDA) for interval-based execution
- pg_listener source plugin (EDA) for real-time event handling

## Benefits

- No need to build or maintain a custom Kubernetes Operator.
- Reuses existing Ansible and PostgreSQL capabilities.
- Fully event-driven and scalable.
- Clean separation between trigger creation and event handling.
- Modular and environment-agnostic—can be applied to any PostgreSQL-aware infrastructure.

## Summary

Watch Tower leverages Event-Driven Ansible to monitor PostgreSQL in a highly responsive and declarative way. By using native PostgreSQL features like `pg_notify` and integrating them into Ansible rulebooks, this approach replaces the need for a complex Kubernetes Operator and still achieves automatic, intelligent scaling of the AAP control plane based on database state.

---
