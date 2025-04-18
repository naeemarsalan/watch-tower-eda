FROM registry.redhat.io/ansible-automation-platform-25/de-supported-rhel9
# Install PostgreSQL client

RUN rpm -ivh https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm

RUN microdnf install postgresql13-13.20-1PGDG.rhel9.x86_64 -y && \
    microdnf clean all

