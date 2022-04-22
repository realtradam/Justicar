# frozen_string_literal: true

require_relative "Justicar/version"
require "paggio"
require "opal"
require "ostruct"

class Justicar
  class << self

    def load_preprocessors(dir)
      Dir.each_child(dir) do |full_file_name|
        file_name, extension, _rb = full_file_name.split('.')
        if File.directory?("#{dir}/#{full_file_name}")
          self.load_preprocessors("#{dir}/#{full_file_name}")
        else
          if ['pre'].include? extension
            load "#{dir}/#{full_file_name}"
          end
        end
      end
    end

    def build_source(dir, target = self.output)

      # only add root path
      unless self.opl_path
        opl_path = true
        opl.append_paths dir
      end

      Dir.each_child(dir) do |full_file_name|
        file_name, extension, _rb = full_file_name.split('.')
        if File.directory?("#{dir}/#{full_file_name}")
          target[full_file_name] ||= {}
          self.build_source("#{dir}/#{full_file_name}", target[full_file_name])
        else
          # single html and css files
          if ['html', 'css'].include? extension
            File.open("#{dir}/#{full_file_name}", 'r') do |file|
              target[full_file_name] = instance_eval(file.read)
            end
            # does "post processing" and lets you execute custom code depending on preprocessing
          elsif ['post'].include? extension
            File.open("#{dir}/#{full_file_name}", 'r') do |file|
              # use dir and target
              instance_eval(file.read)
            end
          elsif ['js'].include? extension
            opl_file, _dot, _extension = full_file_name.partition('.')
            opl_file = "#{"#{dir}/".partition('/').last}#{opl_file}"
            target[full_file_name] = opl.build(opl_file).to_s
          end
        end
      end
    end

    def build_initialize(target_dir, public_dir, hash = self.output)
      if Dir.exist? target_dir
        FileUtils.rm_r target_dir
      end
      if Dir.exist? public_dir
        FileUtils.copy_entry(public_dir, target_dir)
      else
        FileUtils.mkdir target_dir
      end
      build(target_dir, public_dir, hash)
    end

    def build(target_dir, public_dir, hash = self.output)
      hash.each do |key, val|
        if val.is_a? String
          file_name, type, _rb = key.to_s.split('.')
          File.open("#{target_dir}/#{file_name}.#{type}", "w") do |file|
            file.write(val)
          end
        else
          ensure_dir "#{target_dir}/#{key}"
          self.build("#{target_dir}/#{key}", public_dir, hash[key])
        end
      end
    end

    def ensure_dir(dir)
      unless Dir.exist? dir
        FileUtils.mkdir dir
      end
      File.directory? dir
    end

    def output
      @output ||= {}
    end

    def opl
      @opl ||= Opal::Builder.new
    end

    attr_accessor :opl_path

  end

  PreProcessor = OpenStruct.new

end
