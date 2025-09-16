# Dockerfile for Neo4j

# Set the base image
FROM neo4j:latest

# ARG for build-time variables with default values
# WARNING: Do not use default passwords in production environments.
# Pass the password at build time using --build-arg NEO4J_PASSWORD_ARG=your_secure_password
ARG NEO4J_PASSWORD_ARG=devpass

# Set environment variables
# The password is set from a build-time argument.
# For production, it is strongly recommended to set the password via Docker secrets or at runtime.
# The format for NEO4J_AUTH is <user>/<password>
ENV NEO4J_AUTH=neo4j/${NEO4J_PASSWORD_ARG}

# Expose ports
# 7474 for HTTP
# 7687 for Bolt
EXPOSE 7474 7687

# Set up a volume for data persistence
VOLUME /data

# The base image's default CMD will run Neo4j
