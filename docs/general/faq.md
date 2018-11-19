# FAQ

## How can I FTP/SFTP into the server(s)?

Unfortunately FTP/SFTP server is not possible due to the complexity of the architecture. In simple terms due to the fact applications are deployed to multiple servers means it is not feasible to provide FTP/SFTP access as that would imply accessing
a single implicit server. If the code needs to be modified then the best channel is first via source control and then
deploying a new release. Please refer to the [Deployment](deployment.md) guide for more information.
