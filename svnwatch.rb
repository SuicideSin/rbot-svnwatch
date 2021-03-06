#!/usr/bin/env ruby
#
# svnwatch - a subversion plugin for rbot.
#
# This file should be placed in the rbot plugins/ directroy. When you
# load rbot it will scan the directory and load this plugin. DRb will
# automatically start up.
#
# Copyright (c) 2005, Ben Bleything and Robby Russell
# Released under the terms of the MIT License
#

require 'drb'

# Configuration Options
@conf = {
  :port => '7666',       # 7666 (you will need this to be the same in post-commit)
  :host => 'localhost',  # localhost, don't set to remote ip unless you know what you are doing
  :chan => '#pdx.rb'     # IRC channel that you want rbot to send notices to
}

class SvnWatch < Plugin

  attr_writer :channel

  def privmsg(m)
    m.reply "I don't actually have anything to say. I just sit and wait for SVN to call me."
  end

  def svn_commit(info)
    send_msg(build_msg(info))
  end

  # Sends a message to the channel defined. This will allow
  # you to use the DRb instance to call the send_msg(str)
  # method, which will output to the desired channel
  private
    def send_msg(str)
      @bot.say @channel,  str
    end

    # yes this is really ugly.. we'll clean it up!
    def build_msg(info)
      author = "\00303" + info[:author] + "\017"
      repository = "\00310"  + info[:repository] + "\017"
      revision =  "\002" + "" + info[:revision] + "" + "\017"
      note =  "\00303" + info[:log] +  "\017"
      message = "\00313svn\017\00300.commit\017( \00302#{repository}\017, { \00306:author\017 \002=>\017 '#{author}', \00306:rev\017 \002=>\017 #{revision}, \00306:log\017 \002=>\017 '#{note}' } )"
      return message
    end

end

# register with rbot
@svnwatch = SvnWatch.new
@svnwatch.channel = @conf[:chan]
@svnwatch.register("svnwatch")

# start DRb in a new thread so it doesn't hang up the bot
Thread.new {
  # start the DRb instance
  DRb.start_service("druby://#{@conf[:host]}:#{@conf[:port]}", @svnwatch)
  DRb.thread.join
}

# that's all folks!