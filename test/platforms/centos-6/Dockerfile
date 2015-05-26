FROM <%= @image %>
ENV http_proxy <%= @http_proxy %>
ENV https_proxy <%= @https_proxy %>
ENV LANG <%= @lang %>

RUN echo "proxy=<%= @http_proxy %>" >> /etc/yum.conf
<% if @yum_conf && @yum_conf[:include_only] %>
RUN echo "include_only=<%= @yum_conf[:include_only] %>" >> /etc/yum/pluginconf.d/fastestmirror.conf
<% end %>
RUN yum clean all
RUN yum install -y sudo openssh-server openssh-clients which curl htop
RUN yum install -y git wget tar

RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN mkdir -p /var/run/sshd
RUN useradd -d /home/<%= @username %> -m -s /bin/bash <%= @username %>
RUN echo <%= "#{@username}:#{@password}" %> | chpasswd
RUN echo '<%= @username %> ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN curl -L http://www.opscode.com/chef/install.sh | bash
RUN yum -y install https://opscode-omnibus-packages.s3.amazonaws.com/el/6/x86_64/chefdk-0.6.0-1.el6.x86_64.rpm

RUN touch ./dummy_iptables
RUN cp ./dummy_iptables /etc/init.d/iptables

# proxy
RUN echo "export http_proxy=<%= @http_proxy %>" >> /etc/profile.d/proxy.sh
RUN echo "export https_proxy=<%= @https_proxy %>" >> /etc/profile.d/proxy.sh
RUN echo "export no_proxy=127.0.0.1,localhost" >> /etc/profile.d/proxy.sh
