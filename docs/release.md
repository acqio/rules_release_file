<a name="release"></a>
### release

```python
release(name, files, increments, substitutions)
```

<table class="table table-condensed table-bordered table-implicit">
  <colgroup>
    <col class="col-param" />
    <col class="param-description" />
  </colgroup>
  <thead>
    <tr>
      <th colspan="2">Implicit targets</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code><i>name</i>.apply</code></td>
      <td>
        <code>File modification in workspace</code>
        <p>
          This target changes the file passed in the files attribute in the workspace.
        </p>
      </td>
    </tr>
  </tbody>
</table>

<table class="table table-condensed table-bordered table-params">
  <colgroup>
    <col class="col-param" />
    <col class="param-description" />
  </colgroup>
  <thead>
    <tr>
      <th colspan="2">Attributes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>name</code></td>
      <td>
        <code>Name, required</code>
        <p>A unique name for this rule.</p>
      </td>
    </tr>
    <tr>
      <td><code>files</code></td>
      <td>
        <code>The list of files `.json`s or `yaml`s, required</code>
        <p>
          A list of files that should be used as the basis for the new release files.
        </p>
      </td>
    </tr>
    <tr>
      <td><code>increments</code></td>
      <td>
        <code>Dictionary from strings to strings, optional</code>
        <p>Increment of an integer value existing in a document key.
          The key value can be a string, which contains an integer.</p>
        <p>The increment unit will be the value defined in the dictionary.</p>
        <p>
          <code>
            increments = { "path.to.foo": "1", ... },
          </code>
        </p>
      </td>
    </tr>
    <tr>
      <td><code>substitutions</code></td>
      <td>
        <code>Dictionary from strings to strings, optional</code>
        <p>Raw substitution of the value of a given document key.</p>
        <p>This field supports stamp variables.</p>
        <p>
          <code>
            substitutions = { "path.to.foo": "{BUILD_TIMESTAMP}", "path.to.bar": "20.02.02", ... },
          </code>
        </p>
      </td>
    </tr>
  </tbody>
</table>
